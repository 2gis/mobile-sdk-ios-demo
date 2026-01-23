import DGis
import SwiftUI

class RouteSearchNGDemoViewModel: ObservableObject, @unchecked Sendable {
	private enum Constants {
		static let aPointAttributes: [String: AttributeValue] = ["db_sublayer": .string("s_dvg_transport_point_a")]
		static let bPointAttributes: [String: AttributeValue] = ["db_sublayer": .string("s_dvg_transport_point_b")]
		static let intermediatePointAttributes: [String: AttributeValue] = ["db_sublayer": .string("s_dvg_carrouting_point_interim")]
		static let dbPlanId: String = "db_plan_id"
	}

	@Published var pendingLongPressObjectInfo: RenderedObjectInfo?
	@Published private(set) var routePoints: [RoutePointUI] = []

	let routeEditor: RouteEditor
	let map: Map

	private let searchManager: SearchManager
	private let geometrySource: GeometryMapObjectSource
	private var routeEditorSource: RouteEditorSource
	private var searchCancellable: Cancellable?
	private var routesCancellable: Cancellable?
	private var activeRouteCancellable: Cancellable?

	private var cameraPaddingDebounceWorkItem: DispatchWorkItem?
	private var pendingCameraPadding: (insets: EdgeInsets, scale: CGFloat)?
	private var cameraMoveCancellable: Future<CameraAnimatedMoveResult>?
	private var isPublicTransport: Bool = false

	init(
		map: Map,
		routeEditorSourceFactory: @escaping (RouteEditor) -> RouteEditorSource,
		routeEditorFactory: @escaping () -> RouteEditor,
		searchManager: SearchManager,
		geometrySource: GeometryMapObjectSource
	) throws {
		self.map = map
		self.routeEditor = routeEditorFactory()
		self.routeEditorSource = routeEditorSourceFactory(self.routeEditor)
		self.searchManager = searchManager
		self.geometrySource = geometrySource

		self.map.addSource(source: self.routeEditorSource)
		self.map.addSource(source: self.geometrySource)

		self.routesCancellable = self.routeEditor.routesInfoChannel.sinkOnMainThread { routes in
			if case .publicTransport = routes.routeParams.routeSearchOptions {
				self.isPublicTransport = true
			} else {
				self.isPublicTransport = false
			}
			self.routeEditorSource.setShowOnlyActiveRoute(showOnlyActiveRoute: self.isPublicTransport)
			self.calcCameraPositionForRoutes()
		}

		self.activeRouteCancellable = self.routeEditor.activeRouteIndexChannel.sinkOnMainThread { _ in
			guard self.isPublicTransport else { return }
			self.calcCameraPositionForRoutes()
		}
	}

	func addPoint(routePointUI: RoutePointUI) {
		let attributes: [String: AttributeValue] = switch self.routePoints.count {
		case 0:
			Constants.aPointAttributes
		case 1:
			Constants.bPointAttributes
		default:
			Constants.intermediatePointAttributes
		}

		guard let pointObject = createPointGeometryMapObject(
			routePointUI.point.coordinates,
			attributes: attributes,
			levelId: nil
		) else { return }

		self.geometrySource.addObject(item: pointObject)

		if self.routePoints.count >= 2 {
			// Вставляем промежуточную точку перед текущей конечной точкой B
			let insertIndex = self.routePoints.count - 1
			self.routePoints.insert(routePointUI, at: insertIndex)
		} else {
			self.routePoints.append(routePointUI)
		}
	}

	func onLongPressObject(info: RenderedObjectInfo) {
		guard let mapObject = info.item.item as? DgisMapObject else { return }
		self.searchCancellable = self.searchManager.searchByDirectoryObjectId(objectId: mapObject.id).sinkOnMainThread(
			receiveValue: { [weak self] directoryObject in
				let geoPoint = info.closestMapPoint.point
				let routePointUI = if let label = directoryObject?.title {
					RoutePointUI(point: .init(coordinates: geoPoint), label: label)
				} else {
					RoutePointUI.fromGeoPoint(geoPoint)
				}
				self?.addPoint(routePointUI: routePointUI)
			},
			failure: { _ in }
		)
	}

	func onTapObject(info: RenderedObjectInfo) {
		guard let route: RouteMapObject = info.item.item as? RouteMapObject,
		      routeEditor.activeRouteIndex != route.routeIndex else { return }
		self.routeEditor.setActiveRouteIndex(index: route.routeIndex)
	}

	func calcCameraPositionForRoutes() {
		let geometry: Geometry
		if self.isPublicTransport {
			guard let activeRouteIndex = self.routeEditor.activeRouteIndex?.value else { return }
			geometry = toMapGeometry(geometry: self.routeEditor.routesInfo.routes[Int(activeRouteIndex)].route.geometry)
		} else {
			let routesGeometries = self.routeEditor.routesInfo.routes.map { toMapGeometry(geometry: $0.route.geometry) }
			guard !routesGeometries.isEmpty else { return }
			geometry = ComplexGeometry(geometries: routesGeometries)
		}

		let position = calcPosition(
			camera: self.map.camera,
			geometry: geometry
		)
		self.cameraMoveCancellable = self.map.camera.move(position: position, time: 0.5, animationType: .linear)
	}

	func applyCameraPaddings(insets: EdgeInsets, scale: CGFloat) {
		self.map.camera.padding = .init(
			left: Self.toUInt32Points(insets.leading, scale: scale),
			top: Self.toUInt32Points(insets.top, scale: scale),
			right: Self.toUInt32Points(insets.trailing, scale: scale),
			bottom: Self.toUInt32Points(insets.bottom, scale: scale)
		)
	}

	private static func toUInt32Points(_ value: CGFloat, scale: CGFloat) -> UInt32 {
		let scaled = value * scale
		if scaled.isNaN || scaled.isInfinite { return 0 }
		return UInt32(max(0, scaled).rounded())
	}

	private func createPointGeometryMapObject(
		_ point: GeoPoint?,
		attributes: [String: AttributeValue],
		levelId: LevelId?
	) -> GeometryMapObject? {
		guard let point else { return nil }
		var objectAttributes = attributes
		if let levelId {
			objectAttributes[Constants.dbPlanId] = .integer(Int64(levelId.value))
		}
		return GeometryMapObjectBuilder()
			.setGeometry(geometry: PointGeometry(point: point))
			.setDraggable(draggable: true)
			.setObjectAttributes(values: objectAttributes)
			.createObject()
	}
}
