import CoreLocation
import DGis
import SwiftUI

class RouteEditorControlDemoViewModel: ObservableObject, @unchecked Sendable {
	enum RoutePointType {
		case pointA, pointB, intermediate
	}

	private enum Constants {
		static let aPointAttributes: [String: AttributeValue] = ["db_sublayer": .string("s_dvg_transport_point_a")]
		static let bPointAttributes: [String: AttributeValue] = ["db_sublayer": .string("s_dvg_transport_point_b")]
		static let intermediatePointAttributes: [String: AttributeValue] = ["db_sublayer": .string("s_dvg_carrouting_point_interim")]
		static let dbPlanId: String = "db_plan_id"
	}

	@Published var pendingLongPressObjectInfo: RenderedObjectInfo?
	@Published private(set) var routePoints: [RoutePointUI] = []

	let routeEditor: RouteEditor

	private let mapFactory: IMapFactory
	private let searchManager: SearchManager
	private let geometrySource: GeometryMapObjectSource
	private let routeEditorSource: RouteEditorSource
	private let myLocationMapObjectSource: MyLocationMapObjectSource
	private let locationService: DGis.LocationService

	private var searchCancellable: Cancellable?
	private var routesCancellable: Cancellable?
	private var activeRouteCancellable: Cancellable?
	private var cameraSizeCancellable: Cancellable?

	private var cameraPaddingDebounceWorkItem: DispatchWorkItem?
	private var pendingCameraPadding: (insets: EdgeInsets, scale: CGFloat)?
	private var cameraMoveCancellable: Future<CameraAnimatedMoveResult>?
	private var isPublicTransport: Bool = false

	private var pointAObject: GeometryMapObject?
	private var pointBObject: GeometryMapObject?
	private var configureMapTask: Task<Void, Never>?

	private var map: Map {
		self.mapFactory.map
	}

	init(
		mapFactory: IMapFactory,
		routeEditorSourceFactory: @escaping (RouteEditor) -> RouteEditorSource,
		routeEditorFactory: @escaping () -> RouteEditor,
		searchManager: SearchManager,
		geometrySource: GeometryMapObjectSource,
		myLocationMapObjectSource: MyLocationMapObjectSource,
		locationService: DGis.LocationService
	) throws {
		self.mapFactory = mapFactory
		self.routeEditor = routeEditorFactory()
		self.routeEditorSource = routeEditorSourceFactory(self.routeEditor)
		self.searchManager = searchManager
		self.geometrySource = geometrySource
		self.myLocationMapObjectSource = myLocationMapObjectSource
		self.locationService = locationService

		self.configureMapTask = Task { @MainActor [weak self] in
			guard let self else { return }
			do {
				let map = try await self.mapFactory.mapAsync
				map.addSource(source: self.routeEditorSource)
				map.addSource(source: self.geometrySource)
				map.addSource(source: self.myLocationMapObjectSource)

				self.routesCancellable = self.routeEditor.routesInfoChannel.sinkOnMainThread { [weak self] routes in
					Task { @MainActor [weak self] in
						guard let self else { return }
						if case .publicTransport = routes.routeParams.routeSearchOptions {
							self.isPublicTransport = true
						} else {
							self.isPublicTransport = false
						}
						self.routeEditorSource.setShowOnlyActiveRoute(showOnlyActiveRoute: self.isPublicTransport)
						self.calcCameraPositionForRoutes()
						let isPointsVisible = routes.routes.count == 0
						self.pointAObject?.isVisible = isPointsVisible
						self.pointBObject?.isVisible = isPointsVisible
					}
				}

				self.activeRouteCancellable = self.routeEditor.activeRouteIndexChannel.sinkOnMainThread { [weak self] _ in
					Task { @MainActor [weak self] in
						guard let self else { return }
						guard self.isPublicTransport else { return }
						self.calcCameraPositionForRoutes()
					}
				}
			} catch {
			print("Failed to configure route editor control map: \(error)")
			}
		}
	}

	deinit {
		self.configureMapTask?.cancel()
	}

	func addPoint(routePointUI: RoutePointUI, type: RoutePointType) {
		let attributes: [String: AttributeValue] = switch type {
		case .pointA:
			Constants.aPointAttributes
		case .pointB:
			Constants.bPointAttributes
		case .intermediate:
			Constants.intermediatePointAttributes
		}

		guard let pointObject = createPointGeometryMapObject(
			routePointUI.point.coordinates,
			attributes: attributes,
			levelId: nil
		) else { return }

		switch type {
		case .pointA:
			if let pointAObject {
				self.geometrySource.removeObject(item: pointAObject)
				self.pointAObject = pointObject
			} else {
				self.pointAObject = pointObject
			}
		case .pointB:
			if let pointBObject {
				self.geometrySource.removeObject(item: pointBObject)
				self.pointBObject = pointObject
			} else {
				self.pointBObject = pointObject
			}
		default: break
		}

		self.geometrySource.addObject(item: pointObject)

		switch type {
		case .pointA:
			if self.routePoints.isEmpty {
				self.routePoints.append(routePointUI)
			} else {
				self.routePoints[0] = routePointUI
			}
		case .pointB:
			switch self.routePoints.count {
			case 0:
				guard let coordinate = self.locationService.lastLocation else { return }
				self.routePoints.append(
					RoutePointUI(
						point: .init(coordinates: coordinate.coordinates.value),
						label: String(localized: "My location")
					)
				)
				self.routePoints.append(routePointUI)
			case 1:
				self.routePoints.append(routePointUI)
			default:
				_ = self.routePoints.popLast()
				self.routePoints.append(routePointUI)
			}
		case .intermediate:
			self.routePoints.insert(routePointUI, at: self.routePoints.count - 1)
		}
	}

	func onLongPressObject(info: RenderedObjectInfo, type: RoutePointType) {
		guard let mapObject = info.item.item as? DgisMapObject else { return }
		self.searchCancellable = self.searchManager.searchByDirectoryObjectIds(objectIds: [mapObject.id]).sinkOnMainThread(
			receiveValue: { [weak self] directoryObjects in
				let directoryObject = directoryObjects.first
				let geoPoint = info.closestMapPoint.point
				let routePointUI = if let object = directoryObject {
					RoutePointUI(point: .init(coordinates: geoPoint, objectId: object.id ?? .init(), levelId: object.levelId), label: object.title)
				} else {
					RoutePointUI.fromGeoPoint(geoPoint)
				}
				Task { @MainActor [weak self] in
					self?.addPoint(routePointUI: routePointUI, type: type)
				}
			},
			failure: { _ in }
		)
	}

	func onTapObject(info: RenderedObjectInfo) {
		guard let route: RouteMapObject = info.item.item as? RouteMapObject,
		      routeEditor.activeRouteIndex != route.routeIndex else { return }
		try? self.routeEditor.setActiveRouteIndex(index: route.routeIndex)
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

		self.cameraSizeCancellable = self.map.camera.sinkOnStatefulChangesOnMainThread(reason: .size) {
			[weak self] (_: ScreenSize) in
			Task { @MainActor [weak self] in
				guard let self else { return }
				guard let position = try? calcPosition(
					camera: self.map.camera,
					geometry: geometry
				) else {
					return
				}
				self.cameraMoveCancellable = self.map.camera.move(position: position, time: 0.5, animationType: .linear)
			}
		}
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
