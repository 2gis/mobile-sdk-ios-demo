import SwiftUI
import DGis

enum TransportType: Int, CaseIterable {
	case car, publicTransport, bicycle, pedestrian, taxi, truck

	var name: String {
		switch self {
			case .car:
				return "Car"
			case .publicTransport:
				return "Public transport"
			case .truck:
				return "Truck"
			case .taxi:
				return "Taxi"
			case .pedestrian:
				return "Pedestrian"
			case .bicycle:
				return "Bicycle"
		}
	}
}

final class RouteViewModel: ObservableObject {
	enum State {
		case buildRoutePoints
		case readyToSearch
		case routesSearch
		case routesFound
		case routesNotFound
	}

	private enum Constants {
		static let aPointAttributes: [String: AttributeValue] = ["db_sublayer": .string("s_dvg_transport_point_a")]
		static let bPointAttributes: [String: AttributeValue] = ["db_sublayer": .string("s_dvg_transport_point_b")]
		static let pointSearchRadius: Float = 44
	}

	@Published var state: State = .buildRoutePoints
	@Published var pointADescription: String? = nil
	@Published var pointBDescription: String? = nil
	@Published private(set) var hasRoutes = false
	@Published private(set) var showRouteListOption = false

	var shouldShowSearchRouteButton: Bool {
		[.readyToSearch, .routesNotFound].contains(self.state)
	}
	var shouldShowRemoveRouteButton: Bool {
		self.state == .routesFound
	}
	let transportType: TransportType
	var routeEditorRoutesInfo: RouteEditorRoutesInfo? {
		return self.routeEditor.routesInfo
	}
	private let carRouteSearchOptions: CarRouteSearchOptions
	private let publicTransportRouteSearchOptions: PublicTransportRouteSearchOptions
	private let truckRouteSearchOptions: TruckRouteSearchOptions
	private let taxiRouteSearchOptions: TaxiRouteSearchOptions
	private let bicycleRouteSearchOptions: BicycleRouteSearchOptions
	private let pedestrianRouteSearchOptions: PedestrianRouteSearchOptions

	private var pointA: GeoPoint? = nil {
		didSet {
			self.pointADescription = "A: " + self.pointA.pointDescription
		}
	}
	private var pointB: GeoPoint? = nil {
		didSet {
			self.pointBDescription = "B: " + self.pointB.pointDescription
		}
	}
	private var pointAMapObject: GeometryMapObject? = nil
	private var pointBMapObject: GeometryMapObject? = nil
	private var draggedMapObject: GeometryMapObject?
	private let toMapTransform: CGAffineTransform

	private let sourceFactory: () -> ISourceFactory
	private let routeEditorSourceFactory: (RouteEditor) -> RouteEditorSource
	private let routeEditorFactory: () -> RouteEditor
	private let map: Map
	private let feedbackGenerator: FeedbackGenerator
	private lazy var geometryObjectSource: GeometryMapObjectSource = {
		self.sourceFactory().createGeometryMapObjectSourceBuilder().createSource()
	}()

	private lazy var routeEditor = self.routeEditorFactory()
	private lazy var source = self.routeEditorSourceFactory(self.routeEditor)

	private var routeInfoCancellable: ICancellable = NoopCancellable()

	init(
		transportType: TransportType,
		carRouteSearchOptions: CarRouteSearchOptions,
		publicTransportRouteSearchOptions: PublicTransportRouteSearchOptions,
		truckRouteSearchOptions: TruckRouteSearchOptions,
		taxiRouteSearchOptions: TaxiRouteSearchOptions,
		bicycleRouteSearchOptions: BicycleRouteSearchOptions,
		pedestrianRouteSearchOptions: PedestrianRouteSearchOptions,
		sourceFactory: @escaping () -> ISourceFactory,
		routeEditorSourceFactory: @escaping (RouteEditor) -> RouteEditorSource,
		routeEditorFactory: @escaping () -> RouteEditor,
		map: Map,
		feedbackGenerator: FeedbackGenerator
	) {
		self.transportType = transportType
		self.carRouteSearchOptions = carRouteSearchOptions
		self.publicTransportRouteSearchOptions = publicTransportRouteSearchOptions
		self.truckRouteSearchOptions = truckRouteSearchOptions
		self.taxiRouteSearchOptions = taxiRouteSearchOptions
		self.bicycleRouteSearchOptions = bicycleRouteSearchOptions
		self.pedestrianRouteSearchOptions = pedestrianRouteSearchOptions
		self.sourceFactory = sourceFactory
		self.routeEditorSourceFactory = routeEditorSourceFactory
		self.routeEditorFactory = routeEditorFactory
		self.map = map
		self.feedbackGenerator = feedbackGenerator

		let scale = UIScreen.main.nativeScale
		self.toMapTransform = CGAffineTransform(scaleX: scale, y: scale)

		self.map.addSource(source: self.geometryObjectSource)
		self.updatePointA(nil)
		self.updatePointB(nil)
		self.routeInfoCancellable = self.routeEditor.routesInfoChannel.sinkOnMainThread { [weak self] info in
			self?.handle(info)
		}
	}

	deinit {
		self.removeRoute()
	}

	func setupPointA() {
		_ = self.map.camera.positionChannel.sinkOnMainThread { [weak self] position in
			self?.updatePointA(position.point)
		}
	}

	func setupPointB() {
		_ = self.map.camera.positionChannel.sinkOnMainThread { [weak self] position in
			self?.updatePointB(position.point)
		}
	}

	func findRoute() {
		guard
			let routeParams = self.buildRouteEditorRouteParams(),
			self.routeEditor.routesInfo.routeParams != routeParams
		else {
			return
		}
		self.state = .routesSearch

		self.source.setRoutesVisible(visible: true)
		if !self.map.sources.contains(self.source) {
			self.map.addSource(source: self.source)
		}
		self.routeEditor.setRouteParams(routeParams: routeParams)
	}

	func removeRoute() {
		self.state = .buildRoutePoints
		self.map.removeSource(source: self.source)
		self.showRouteListOption = false
		self.pointA = nil
		self.pointB = nil
		self.remove(geometryMapObject: self.pointAMapObject)
		self.remove(geometryMapObject: self.pointBMapObject)
		self.pointAMapObject = nil
		self.pointBMapObject = nil
	}

	private func handle(_ info: RouteEditorRoutesInfo) {
		self.showRouteListOption = !info.routes.isEmpty && self.transportType == .publicTransport
		if self.state == .routesSearch {
			if info.routes.isEmpty {
				self.state = .routesNotFound
			} else {
				self.state = .routesFound
			}
		}
	}

	private func updatePointA(_ point: GeoPoint?) {
		self.pointA = point
		self.hasRoutes = self.pointA != nil && self.pointB != nil
		self.remove(geometryMapObject: self.pointAMapObject)
		if let pointObject = self.createPointGeometryMapObject(point, attributes: Constants.aPointAttributes) {
			self.pointAMapObject = pointObject
			self.geometryObjectSource.addObject(item: pointObject)
		}
		self.handleRoutePointsUpdate()
	}

	private func updatePointB(_ point: GeoPoint?) {
		self.pointB = point
		self.hasRoutes = self.pointA != nil && self.pointB != nil
		self.remove(geometryMapObject: self.pointBMapObject)
		if let pointObject = self.createPointGeometryMapObject(point, attributes: Constants.bPointAttributes) {
			self.pointBMapObject = pointObject
			self.geometryObjectSource.addObject(item: pointObject)
		}
		self.handleRoutePointsUpdate()
	}

	private func handleRoutePointsUpdate() {
		if self.state == .buildRoutePoints, self.pointA != nil, self.pointB != nil {
			self.state = .readyToSearch
		}
		if self.state == .routesFound || self.state == .routesNotFound {
			self.findRoute()
		}
	}

	private func remove(geometryMapObject: GeometryMapObject?) {
		guard let object = geometryMapObject else { return }
		self.geometryObjectSource.removeObject(item: object)
	}

	private func createPointGeometryMapObject(
		_ point: GeoPoint?,
		attributes: [String: AttributeValue]
	) -> GeometryMapObject? {
		guard let point = point else { return nil }
		return GeometryMapObjectBuilder()
			.setGeometry(geometry: PointGeometry(point: point))
			.setDraggable(draggable: true)
			.setObjectAttributes(values: attributes)
			.createObject()
	}

	private func buildRouteEditorRouteParams() -> RouteEditorRouteParams? {
		guard let pointA = self.pointA, let pointB = self.pointB else { return nil }

		let startSearchPoint = RouteSearchPoint(
			coordinates: pointA,
			course: nil,
			objectId: DgisObjectId(objectId: 0, entranceId: 0)
		)

		let finishSearchPoint = RouteSearchPoint(
			coordinates: pointB,
			course: nil,
			objectId: DgisObjectId(objectId: 1, entranceId: 0)
		)

		let routeSearchOptions: RouteSearchOptions
		switch self.transportType {
			case .car:
				routeSearchOptions = .car(self.carRouteSearchOptions)
			case .publicTransport:
				routeSearchOptions = .publicTransport(self.publicTransportRouteSearchOptions)
			case .truck:
				routeSearchOptions = .truck(self.truckRouteSearchOptions)
			case .taxi:
				routeSearchOptions = .taxi(self.taxiRouteSearchOptions)
			case .bicycle:
				routeSearchOptions = .bicycle(self.bicycleRouteSearchOptions)
			case .pedestrian:
				routeSearchOptions = .pedestrian(self.pedestrianRouteSearchOptions)
		}
		return RouteEditorRouteParams(
			startPoint: startSearchPoint,
			finishPoint: finishSearchPoint,
			routeSearchOptions: routeSearchOptions,
			intermediatePoints: []
		)
	}
}

extension RouteViewModel {
	func handleDragGesture(_ state: LongPressAndDragRecognizerState) {
		switch state {
			case .started(let location):
				if let pointObject = self.getPointObject(at: location) {
					self.feedbackGenerator.impactFeedback()
					self.map.interactive = false
					self.draggedMapObject = pointObject
				}
			case.changed(let location):
				self.moveRoutePointMapObject(self.draggedMapObject, to: location)
			case .inactive:
				if self.draggedMapObject != nil {
					self.map.interactive = true
					self.draggedMapObject = nil
					self.handleRoutePointsUpdate()
				}
		}
	}

	private func getPointObject(at location: CGPoint) -> GeometryMapObject? {
		let gestureScreenPoint = ScreenPoint(location.applying(self.toMapTransform))
		let candidates: [(distance: Float, object: GeometryMapObject)] = [self.pointAMapObject, self.pointBMapObject].compactMap {
			guard
				let mapObject = $0,
				let objectScreenPoint = self.map.camera.projection.mapToScreen(point: mapObject.geometry.minPoint)
			else {
				return nil
			}
			let distance = abs(gestureScreenPoint.distance(to: objectScreenPoint))
			if distance <= Constants.pointSearchRadius {
				return (distance, mapObject)
			} else {
				return nil
			}
		}.sorted {
			$0.distance < $1.distance
		}
		return candidates.first?.object
	}

	private func moveRoutePointMapObject(_ mapObject: GeometryMapObject?, to newPoint: CGPoint) {
		guard let mapObject = mapObject else { return }
		let screenPoint = ScreenPoint(newPoint.applying(self.toMapTransform))
		if let point = self.map.camera.projection.screenToMap(point: screenPoint) {
			mapObject.geometry = PointGeometry(point: point)
			if mapObject == self.pointAMapObject {
				self.pointA = point
			} else {
				self.pointB = point
			}
		}
	}
}

private extension Optional where Wrapped == GeoPoint {
	var pointDescription: String {
		guard let point = self else { return "Not set" }
		return String(format: "lat: %.2f, lon: %.2f", point.latitude.value, point.longitude.value)
	}
}

private extension ScreenPoint {
	func distance(to point: ScreenPoint) -> Float {
		sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
	}
}
