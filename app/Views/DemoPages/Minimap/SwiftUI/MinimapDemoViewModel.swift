import Combine
import DGis
import SwiftUI

final class MinimapDemoViewModel: ObservableObject, @unchecked Sendable {
	enum State {
		case initial
		case routeSearch
		case navigation
		case error(String)
	}

	private enum Constants {
		static let startPoint = GeoPoint(latitude: 55.75710, longitude: 37.6149)
		static let targetPoint = GeoPoint(latitude: 48.480229, longitude: 135.071917)
		static let cameraPositionPoint = CameraPositionPoint(x: 0.5, y: 0.8)
		static let cameraBehaviour = CameraBehaviour(position: .init(bearing: .on, styleZoom: .on))
		static let mapCameraPosition = CameraPosition(point: Constants.startPoint, zoom: Zoom(value: 15))
		static let targetMiniMapCameraPosition = CameraPosition(point: Constants.targetPoint, zoom: Zoom(value: 12))
		static let routeSearchErrorMessage = "Не удалось построить маршрут"
	}

	@Published private(set) var state: State = .initial
	private(set) var navigationManager: NavigationManager
	private let map: Map
	private let miniMap: Map
	private let targetMiniMap: Map
	private let mainMapEnergyConsumption: IEnergyConsumption
	private let miniMapEnergyConsumption: IEnergyConsumption
	private let targetMiniMapEnergyConsumption: IEnergyConsumption
	private let targetMapObjectManager: MapObjectManager
	private let imageFactory: IImageFactory
	private let trafficRouter: TrafficRouter
	private let logger: ILogger
	private var routeSearchCancellable: ICancellable?
	private var cameraStateCancellable: DGis.Cancellable?
	private var isRouteSearchAvailable: Bool {
		switch self.state {
		case .initial, .error:
			true
		case .navigation, .routeSearch:
			false
		@unknown default:
			true
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
		mainMapEnergyConsumption: IEnergyConsumption,
		miniMapEnergyConsumption: IEnergyConsumption,
		targetMiniMapEnergyConsumption: IEnergyConsumption,
		imageFactory: IImageFactory,
		navigationManager: NavigationManager,
		trafficRouter: TrafficRouter,
		logger: ILogger
	) throws {
		self.map = map
		self.miniMap = miniMap
		self.targetMiniMap = targetMiniMap
		self.mainMapEnergyConsumption = mainMapEnergyConsumption
		self.miniMapEnergyConsumption = miniMapEnergyConsumption
		self.targetMiniMapEnergyConsumption = targetMiniMapEnergyConsumption
		self.targetMapObjectManager = MapObjectManager(map: self.targetMiniMap)
		self.imageFactory = imageFactory
		self.navigationManager = navigationManager
		self.trafficRouter = trafficRouter
		self.logger = logger

		try self.map.camera.setPositionPoint(positionPoint: Constants.cameraPositionPoint)
		try self.map.camera.setPosition(position: Constants.mapCameraPosition)
		self.map.camera.setBehaviour(behaviour: Constants.cameraBehaviour)

		try self.targetMiniMap.camera.setPosition(position: Constants.targetMiniMapCameraPosition)
		self.addTargetMarker()

		self.navigationManager.mapManager.addMap(map: map)
	}

	@MainActor
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
		self.cameraStateCancellable = self.map.camera.sinkOnStatefulChangesOnMainThread(reason: .state) { [weak self] (state: CameraState) in
			Task { @MainActor [weak self] in
				guard let self else { return }
				self.handleStateChange(state: state)
			}
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

	@MainActor
	private func handleStateChange(state: CameraState) {
		switch state {
		case .free:
			self.mainMapEnergyConsumption.maxFps = 30
			self.mainMapEnergyConsumption.powerSavingMaxFps = 20
			self.miniMapEnergyConsumption.maxFps = 20
			self.miniMapEnergyConsumption.powerSavingMaxFps = 10
			self.targetMiniMapEnergyConsumption.maxFps = 20
			self.targetMiniMapEnergyConsumption.powerSavingMaxFps = 10
		default:
			self.mainMapEnergyConsumption.maxFps = UIScreen.main.maximumFramesPerSecond
			self.mainMapEnergyConsumption.powerSavingMaxFps = UIScreen.main.maximumFramesPerSecond / 2
			self.miniMapEnergyConsumption.maxFps = 20
			self.miniMapEnergyConsumption.powerSavingMaxFps = 10
			self.targetMiniMapEnergyConsumption.maxFps = 20
			self.targetMiniMapEnergyConsumption.powerSavingMaxFps = 10
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
			try self.targetMapObjectManager.addObject(item: Marker(options: markerOptions))
		} catch let error as SimpleError {
			self.state = .error("Failed to start navigator simulation: \(error.description)")
			self.logger.error("Failed to start navigator simulation: \(error)")
		} catch {
			self.state = .error("Failed to start navigator simulation: \(error.localizedDescription)")
			self.logger.error("Failed to start navigator simulation: \(error)")
		}
	}
}
