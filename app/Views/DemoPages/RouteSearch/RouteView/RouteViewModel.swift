import SwiftUI
import PlatformMapSDK

//final class RouteViewModel: ObservableObject {
//	@Published var pointADescription: String? = nil
//	@Published var pointBDescription: String? = nil
//	@Published private(set) var hasRoutes = false
//	@Published private(set) var hasBuiltRoute = false
//
//	private var pointA: GeoPoint? = nil
//	private var pointB: GeoPoint? = nil
//
//	private let sourceFactory: () -> ISourceFactory
//	private let routeEditorSourceFactory: (RouteEditor) -> RouteEditorSource
//	private let routeEditorFactory: () -> RouteEditor
//	private let map: Map
//
//	private lazy var routeEditor = self.routeEditorFactory()
//	private lazy var source = self.routeEditorSourceFactory(self.routeEditor)
//
//	init(
//		sourceFactory: @escaping () -> ISourceFactory,
//		routeEditorSourceFactory: @escaping (RouteEditor) -> RouteEditorSource,
//		routeEditorFactory: @escaping () -> RouteEditor,
//		map: Map
//	) {
//		self.sourceFactory = sourceFactory
//		self.routeEditorSourceFactory = routeEditorSourceFactory
//		self.routeEditorFactory = routeEditorFactory
//		self.map = map
//
//		self.updatePointA(nil)
//		self.updatePointB(nil)
//	}
//
//	func setupPointA() {
//		_ = self.map.camera.positionChannel.sinkOnMainThread { [weak self] position in
//			self?.updatePointA(position.point)
//		}
//	}
//
//	func setupPointB() {
//		_ = self.map.camera.positionChannel.sinkOnMainThread { [weak self] position in
//			self?.updatePointB(position.point)
//		}
//	}
//
//	func findRoute() {
//		guard let pointA = self.pointA, let pointB = self.pointB else { return }
//
//		self.source.setRoutesVisible(visible: true)
//		self.map.addSource(source: self.source)
//
//		let startSearchPoint = RouteSearchPoint(
//			coordinates: pointA,
//			course: nil,
//			objectId: DirectoryObjectId(value: 0)
//		)
//
//		let finishSearchPoint = RouteSearchPoint(
//			coordinates: pointB,
//			course: nil,
//			objectId: DirectoryObjectId(value: 1)
//		)
//
//		let routeOptions = RouteOptions(
//			avoidTollRoads: false,
//			avoidUnpavedRoads: false,
//			avoidFerry: false
//		)
//
//		let routeParams = RouteParams(
//			startPoint: startSearchPoint,
//			finishPoint: finishSearchPoint,
//			routeOptions: routeOptions,
//			intermediatePoints: []
//		)
//		self.routeEditor.setRouteParams(routeParams: routeParams)
//		self.hasBuiltRoute = true
//	}
//
//	func removeRoute() {
//		self.map.removeSource(source: self.source)
//		self.hasBuiltRoute = false
//	}
//
//	private func updatePointA(_ point: GeoPoint?) {
//		self.pointA = point
//		self.pointADescription = "A: " + self.pointA.pointDescription
//		self.hasRoutes = self.pointA != nil && self.pointB != nil
//	}
//
//	private func updatePointB(_ point: GeoPoint?) {
//		self.pointB = point
//		self.pointBDescription = "B: " + self.pointB.pointDescription
//		self.hasRoutes = self.pointA != nil && self.pointB != nil
//	}
//}
//
//private extension Optional where Wrapped == GeoPoint {
//	var pointDescription: String {
//		guard let point = self else { return "Не установлено" }
//		return String(format: "lat: %.2f, lon: %.2f", point.latitude.value, point.longitude.value)
//	}
//}
