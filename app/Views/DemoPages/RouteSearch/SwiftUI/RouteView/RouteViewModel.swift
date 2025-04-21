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
		static let intermediatePointAttributes: [String: AttributeValue] = ["db_sublayer": .string("s_dvg_carrouting_point_interim")]
		static let dbPlanId: String = "db_plan_id"
		static let pointSearchRadius: Float = 44
		static let tapRadius = ScreenDistance(value: 5.0)
	}

	@Published var state: State = .buildRoutePoints
	@Published var pointADescription: String? = nil
	@Published var pointBDescription: String? = nil
	@Published var intermediatePointsDescription: String? = "Intermediate points count: 0"
	@Published private(set) var hasRoutes = false
	@Published private(set) var showRouteListOption = false

	var shouldShowSearchRouteButton: Bool {
		[.readyToSearch, .routesNotFound].contains(self.state)
	}
	var shouldShowRemoveRouteButton: Bool {
		self.state == .routesFound
	}
	let transportType: TransportType
	let navigationViewFactory: INavigationViewFactory
	var routeEditorRoutesInfo: RouteEditorRoutesInfo? {
		return self.routeEditor.routesInfo
	}
	private let carRouteSearchOptions: CarRouteSearchOptions
	private let publicTransportRouteSearchOptions: PublicTransportRouteSearchOptions
	private let truckRouteSearchOptions: TruckRouteSearchOptions
	private let taxiRouteSearchOptions: TaxiRouteSearchOptions
	private let bicycleRouteSearchOptions: BicycleRouteSearchOptions
	private let pedestrianRouteSearchOptions: PedestrianRouteSearchOptions

	private var pointA: RouteSearchPoint? = nil {
		didSet {
			self.pointADescription = "A: " + self.pointA.pointDescription
		}
	}
	private var pointB: RouteSearchPoint? = nil {
		didSet {
			self.pointBDescription = "B: " + self.pointB.pointDescription
		}
	}
	private var intermediatePoints: [RouteSearchPoint] = [] {
		didSet {
			self.intermediatePointsDescription = "Intermediate points count: \(intermediatePoints.count)"
		}
	}
	private var pointAMapObject: GeometryMapObject? = nil
	private var pointBMapObject: GeometryMapObject? = nil
	private var draggedMapObject: GeometryMapObject?
	private var intermediatePointsMapObjects: [GeometryMapObject] = []
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

	private var pointACancellable: ICancellable = NoopCancellable()
	private var pointBCancellable: ICancellable = NoopCancellable()
	private var routeInfoCancellable: ICancellable = NoopCancellable()
	private var objectIdx: UInt64 = 0

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
		feedbackGenerator: FeedbackGenerator,
		navigationViewFactory: INavigationViewFactory
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
		self.navigationViewFactory = navigationViewFactory

		let scale = UIScreen.main.nativeScale
		self.toMapTransform = CGAffineTransform(scaleX: scale, y: scale)

		self.map.addSource(source: self.geometryObjectSource)
		self.updatePointA(nil)
		self.updatePointB(nil)
		self.routeInfoCancellable = self.routeEditor.routesInfoChannel.sinkOnMainThread({
			[weak self] info in
			self?.handle(info)
		})
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

	func setupIntermediatePoint() {
		_ = self.map.camera.positionChannel.sinkOnMainThread { [weak self] position in
			self?.createIntermediatePoint(position.point)
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
		if self.map.sources.contains(self.source) {
			self.map.removeSource(source: self.source)
		}
		self.pointACancellable.cancel()
		self.pointBCancellable.cancel()
		self.showRouteListOption = false
		self.pointA = nil
		self.pointB = nil
		self.remove(geometryMapObject: self.pointAMapObject)
		self.remove(geometryMapObject: self.pointBMapObject)
		self.pointAMapObject = nil
		self.pointBMapObject = nil
		self.intermediatePoints.removeAll()
		self.intermediatePointsMapObjects.forEach { point in
			self.remove(geometryMapObject: point)
		}
		self.intermediatePointsMapObjects.removeAll()
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
		self.remove(geometryMapObject: self.pointAMapObject)
		self.updatePoint(point: point, pointCancellable: &self.pointACancellable) { [weak self] point, objectInfo in
			self?.pointA = self?.makeRouteSearchPoint(point: point, objectInfo: objectInfo)
			if let pointObject = self?.createPointGeometryMapObject(
				point,
				attributes: Constants.aPointAttributes,
				levelId: objectInfo?.item.levelId
			) {
				self?.pointAMapObject = pointObject
				self?.geometryObjectSource.addObject(item: pointObject)
			}
		}
	}

	private func updatePointB(_ point: GeoPoint?) {
		self.remove(geometryMapObject: self.pointBMapObject)
		self.updatePoint(point: point, pointCancellable: &self.pointBCancellable) { [weak self] point, objectInfo in
			self?.pointB = self?.makeRouteSearchPoint(point: point, objectInfo: objectInfo)
			if let pointObject = self?.createPointGeometryMapObject(
				point,
				attributes: Constants.bPointAttributes,
				levelId: objectInfo?.item.levelId
			) {
				self?.pointBMapObject = pointObject
				self?.geometryObjectSource.addObject(item: pointObject)
			}
		}
	}

	private func createIntermediatePoint(_ point: GeoPoint?) {
		self.updatePoint(point: point, pointCancellable: &self.pointACancellable) { [weak self] point, objectInfo in
			guard let routeSearchPoint = self?.makeRouteSearchPoint(point: point, objectInfo: objectInfo) else { return }
			self?.intermediatePoints.append(routeSearchPoint)
			if let pointObject = self?.createPointGeometryMapObject(
				point,
				attributes: Constants.intermediatePointAttributes,
				levelId: objectInfo?.item.levelId
			) {
				self?.intermediatePointsMapObjects.append(pointObject)
				self?.geometryObjectSource.addObject(item: pointObject)
			}
		}
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
		attributes: [String: AttributeValue],
		levelId: LevelId?
	) -> GeometryMapObject? {
		guard let point = point else { return nil }
		var objectAttributes = attributes
		if let levelId = levelId {
			objectAttributes[Constants.dbPlanId] = .integer(Int64(levelId.value))
		}
		return GeometryMapObjectBuilder()
			.setGeometry(geometry: PointGeometry(point: point))
			.setDraggable(draggable: true)
			.setObjectAttributes(values: objectAttributes)
			.createObject()
	}

	private func buildRouteEditorRouteParams() -> RouteEditorRouteParams? {
		guard let pointA = self.pointA, let pointB = self.pointB else { return nil }

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
			startPoint: pointA,
			finishPoint: pointB,
			routeSearchOptions: routeSearchOptions,
			intermediatePoints: self.intermediatePoints
		)
	}

	private func updatePoint(
		point: GeoPoint?,
		pointCancellable: inout ICancellable,
		updatePointCallback: @escaping (GeoPoint?, RenderedObjectInfo?) -> Void
	) {
		pointCancellable.cancel()
		guard
			let point = point,
			let screenPoint = self.map.camera.projection.mapToScreen(point: point)
		else {
			updatePointCallback(nil, nil)
			self.hasRoutes = self.pointA != nil && self.pointB != nil
			self.handleRoutePointsUpdate()
			return
		}

		pointCancellable = self.map.getRenderedObjects(centerPoint: screenPoint, radius: Constants.tapRadius).sinkOnMainThread(
			receiveValue: { [weak self] infos in
				updatePointCallback(point, infos.first)
				self?.hasRoutes = self?.pointA != nil && self?.pointB != nil
				self?.handleRoutePointsUpdate()
			},
			failure: { [weak self] _ in
				updatePointCallback(point, nil)
				self?.hasRoutes = self?.pointA != nil && self?.pointB != nil
				self?.handleRoutePointsUpdate()
			}
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
				self.updatePoint(point: point, pointCancellable: &self.pointACancellable) { [weak self] point, objectInfo in
					self?.pointA = self?.makeRouteSearchPoint(point: point, objectInfo: objectInfo)
				}
			} else {
				self.updatePoint(point: point, pointCancellable: &self.pointBCancellable) { [weak self] point, objectInfo in
					self?.pointB = self?.makeRouteSearchPoint(point: point, objectInfo: objectInfo)
				}
			}
		}
	}

	private func makeRouteSearchPoint(point: GeoPoint?, objectInfo: RenderedObjectInfo?) -> RouteSearchPoint? {
		guard let point = point else {
			return nil
		}

		guard let objectInfo = objectInfo else {
			let idx = self.objectIdx
			self.objectIdx += 1
			return RouteSearchPoint(
				coordinates: point,
				course: nil,
				objectId: DgisObjectId(objectId: idx, entranceId: 0)
			)
		}

		let objectId: DgisObjectId
		if let dgisMapObject = objectInfo.item.item as? DgisMapObject {
			objectId = dgisMapObject.id
		} else {
			let idx = self.objectIdx
			self.objectIdx += 1
			objectId = DgisObjectId(objectId: idx, entranceId: 0)
		}

		return RouteSearchPoint(
			coordinates: point,
			course: nil,
			objectId: objectId,
			levelId: objectInfo.item.levelId
		)
	}
}

private extension Optional where Wrapped == RouteSearchPoint {
	var pointDescription: String {
		guard let point = self?.coordinates else { return "Not set" }
		return String(format: "lat: %.2f, lon: %.2f", point.latitude.value, point.longitude.value)
	}
}

private extension ScreenPoint {
	func distance(to point: ScreenPoint) -> Float {
		sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
	}
}
