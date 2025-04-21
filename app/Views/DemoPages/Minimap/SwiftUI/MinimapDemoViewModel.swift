import SwiftUI
import Combine
import DGis

final class MinimapDemoViewModel: ObservableObject {
	enum State {
		case initial
		case routeSearch
		case navigation
		case error(String)
	}
	private enum Constants {
		static let startPoint = GeoPoint(latitude: 55.75710, longitude: 37.6149)
		static let targetPoint = GeoPoint(latitude: 57.6276827, longitude: 39.8710012)
		static let cameraPositionPoint = CameraPositionPoint(x: 0.5, y: 0.8)
		static let cameraBehaviour =  CameraBehaviour(position: .init(bearing: .on, styleZoom: .on))
		static let miniMapCameraBehaviour =  CameraBehaviour(position: .init(bearing: .on, styleZoom: .off))
		static let mapCameraPosition = CameraPosition(point: Constants.startPoint, zoom: Zoom(value: 15))
		static let miniMapCameraPosition = CameraPosition(point: Constants.startPoint, zoom: Zoom(value: 12))
		static let targetMiniMapCameraPosition = CameraPosition(point: Constants.targetPoint, zoom: Zoom(value: 12))
		static let routeSearchErrorMessage = "Не удалось построить маршрут"
	}


	@Published private(set) var state: State = .initial
	private let map: Map
	private let miniMap: Map
	private let targetMiniMap: Map
	private let targetMapObjectManager: MapObjectManager
	private let imageFactory: IImageFactory
	private let navigationManager: NavigationManager
	private let trafficRouter: TrafficRouter
	private let logger: ILogger
	private var routeSearchCancellable: ICancellable?
	private var isRouteSearchAvailable: Bool {
		switch self.state {
			case .initial, .error:
				return true
			case .navigation, .routeSearch:
				return false
		}
	}

	private lazy var targetMarkerIcon: DGis.Image = {
		let icon = UIImage(systemName: "mappin.and.ellipse")!
			.withTintColor(#colorLiteral(red: 0.2470588235, green: 0.6, blue: 0.1607843137, alpha: 1))
			.withConfiguration(UIImage.SymbolConfiguration(scale: .large))
		return self.imageFactory.make(image: icon)
	}()

	init(
		map: Map,
		miniMap: Map,
		targetMiniMap: Map,
		imageFactory: IImageFactory,
		mapSourceFactory: IMapSourceFactory,
		navigationManager: NavigationManager,
		trafficRouter: TrafficRouter,
		logger: ILogger
	) throws {
		self.map = map
		self.miniMap = miniMap
		self.targetMiniMap = targetMiniMap
		self.targetMapObjectManager = MapObjectManager(map: self.targetMiniMap)
		self.imageFactory = imageFactory
		self.navigationManager = navigationManager
		self.trafficRouter = trafficRouter
		self.logger = logger

		try self.map.camera.setPositionPoint(positionPoint: Constants.cameraPositionPoint)
		try self.map.camera.setPosition(position: Constants.mapCameraPosition)
		self.map.camera.setBehaviour(behaviour: Constants.cameraBehaviour)

		self.miniMap.interactive = false
		try self.miniMap.camera.setPositionPoint(positionPoint: Constants.cameraPositionPoint)
		try self.miniMap.camera.setPosition(position: Constants.miniMapCameraPosition)
		self.miniMap.camera.setBehaviour(behaviour: Constants.miniMapCameraBehaviour)

		self.targetMiniMap.interactive = false
		try self.targetMiniMap.camera.setPosition(position: Constants.targetMiniMapCameraPosition)
		self.addTargetMarker()

		self.navigationManager.mapManager.addMap(map: map)
		self.navigationManager.mapManager.addMap(map: miniMap)
	}

	func startNavigation() {
		guard self.isRouteSearchAvailable else { return }
		self.state = .routeSearch
		self.routeSearchCancellable?.cancel()
		
		let startPoint = RouteSearchPoint(coordinates: Constants.startPoint)
		let finishPoint = RouteSearchPoint(coordinates: Constants.targetPoint)
		let routeSearchOptions = RouteSearchOptions.car(.init())
		self.routeSearchCancellable = self.trafficRouter.findRoute(
			startPoint: startPoint,
			finishPoint: finishPoint,
			routeSearchOptions: routeSearchOptions
		).sinkOnMainThread { [weak self] routes in
			if let route = routes.first {
				self?.handle(route, finishPoint: finishPoint, routeSearchOptions: routeSearchOptions)
			} else {
				let errorMessage = Constants.routeSearchErrorMessage
				self?.state = .error(errorMessage)
			}
		} failure: { [weak self] error in
			self?.state = .error("\(Constants.routeSearchErrorMessage) \(error.localizedDescription)")
			self?.logger.error("Unable to find route: \(error)")
		}
	}
	
	func stopNavigation() {
		self.navigationManager.stop()
	}

	private func handle(
		_ route: TrafficRoute,
		finishPoint: RouteSearchPoint,
		routeSearchOptions: RouteSearchOptions
	) {
		do {
			try self.navigationManager.startSimulation(
				routeBuildOptions: .init(finishPoint: finishPoint, routeSearchOptions: routeSearchOptions),
				trafficRoute: route
			)
			self.state = .navigation
		} catch let error as SimpleError {
			self.state = .error("Failed to start navigator simulation: \(error.description)")
			self.logger.error("Failed to start navigator simulation: \(error)")
		} catch {
			self.state = .error("Failed to start navigator simulation: \(error.localizedDescription)")
			self.logger.error("Failed to start navigator simulation: \(error)")
		}
	}

	private func addTargetMarker() {
		let markerOptions = MarkerOptions(
			position: .init(point: Constants.targetPoint),
			icon: self.targetMarkerIcon,
			text: "Target",
			iconWidth: .init(value: 30)
		)

		do {
			self.targetMapObjectManager.addObject(item: try Marker(options: markerOptions))
		} catch let error as SimpleError {
			self.state = .error("Failed to start navigator simulation: \(error.description)")
			self.logger.error("Failed to start navigator simulation: \(error)")
		} catch {
			self.state = .error("Failed to start navigator simulation: \(error.localizedDescription)")
			self.logger.error("Failed to start navigator simulation: \(error)")
		}
	}
}
