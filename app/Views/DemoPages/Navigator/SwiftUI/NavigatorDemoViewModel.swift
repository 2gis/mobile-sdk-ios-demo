import Combine
import CoreLocation
import DGis
import SwiftUI

enum StyleZoomFollowControllerType: CaseIterable, PickerViewOption {
	case `default`, custom

	var id: StyleZoomFollowControllerType { self }
	var name: String {
		switch self {
		case .default:
			return "Default"
		case .custom:
			return "Custom"
		@unknown default:
			assertionFailure("Unknown type: \(self)")
			return "Unknown type: \(self)"
		}
	}
}

@MainActor
final class NavigatorDemoViewModel: ObservableObject, @unchecked Sendable {
	private enum Constants {
		static let kmhToMs = 1 / 3.6
		static let minStyleZoom: Double = 15.0
		static let maxStyleZoom: Double = 18.0
		static let animationDuration = abs(maxStyleZoom - minStyleZoom) * 1000
		static let mapState = "Global/MapStateInNavigator"
		static let defaultStyleZoomFollowControllerType: StyleZoomFollowControllerType = .default
		static let tapRadius = ScreenDistance(value: 5.0)
	}

	enum RequestType: Identifiable {
		var id: ObjectIdentifier {
			ObjectIdentifier(Self.self)
		}

		case routeSelection([TrafficRoute])
		case addIntermediatePoint(RouteSearchPoint)
	}

	enum State {
		case targetPointSearch
		case routeSearch
		case routeSelection(RouteSearchPoint, NavigatorOptions)
		case navigation
		case navigationFinished
	}

	private enum TouchType {
		case tap
		case longPress
	}

	@Published var state: State = .targetPointSearch {
		didSet {
			self.stateChangedCallback?()
		}
	}

	@Published var isErrorAlertShown: Bool = false
	@Published var request: RequestType? {
		didSet {
			self.requestChangedCallback?()
		}
	}

	@Published var styleZoomFollowControllerType: StyleZoomFollowControllerType {
		didSet {
			if oldValue != self.styleZoomFollowControllerType {
				switch self.styleZoomFollowControllerType {
				case .default:
					self.stopStyleZoomVariation()
				case .custom:
					self.startStyleZoomVariation()
				@unknown default:
					assertionFailure("Unknown type: \(self)")
				}
			}
		}
	}

	@Published var showCloseMenu: Bool = false
	@Published var isMiniMapSelected: Bool {
		didSet {
			self.settingsService.isMiniMapSelected = self.isMiniMapSelected
		}
	}

	var isStopNavigationButtonVisible: Bool {
		self.isTargetPointSearchInProgress
	}

	var showTargetPointPicker: Bool {
		self.isTargetPointSearchInProgress
	}

	var showRouteSearchMessage: Bool {
		guard case .routeSearch = self.state else { return false }
		return true
	}

	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	let navigatorSettingsViewModel: NavigatorSettingsViewModel
	let settingsService: ISettingsService
	var navigatorModel: DGis.Model {
		self.navigationManager.uiModel
	}

	var mapId: String {
		"\(self.map.id.value)"
	}

	var isFreeRoam: Bool {
		self.navigatorModel.isFreeRoam
	}

	let navigationManager: NavigationManager
	var stateChangedCallback: (() -> Void)?
	var requestChangedCallback: (() -> Void)?
	var roadEventCardPresenterCallback: ((RoadEvent) -> Void)?

	private var isTargetPointSearchInProgress: Bool {
		guard case .targetPointSearch = self.state else { return false }
		return true
	}

	private let map: Map
	private let mainMapEnergyConsumption: IEnergyConsumption
	private var miniMapEnergyConsumption: IEnergyConsumption?
	private let trafficRouter: TrafficRouter
	private let locationService: ILocationService
	private let voiceManager: VoiceManager
	private var applicationIdleTimerService: IApplicationIdleTimerService
	private let imageFactory: IImageFactory
	private let styleZoomFollowController = PlatformStyleZoomFollowController()

	private var routeSearchCancellable: ICancellable?
	private var navigationStateCancellable: ICancellable?
	private var voiceChangedCancellable: AnyCancellable?
	private var getRenderedObjectsCancellable: ICancellable?
	private var styleZoomFollowControllerTypeCancellable: AnyCancellable?
	private var cameraStateCancellable: DGis.Cancellable?
	private var isVoiceConfigured: Bool = false
	private var styleZoomAnimator: ValueAnimator?
	private var intermediatePoints: [RouteSearchPoint] = []
	private let logger: ILogger
	private lazy var storage: IKeyValueStorage = UserDefaults.standard
	private lazy var mapObjectManager: MapObjectManager = .init(map: self.map)
	private lazy var intermediatePointMarkerIcon: DGis.Image = {
		let icon = UIImage(systemName: "mappin.and.ellipse")!
			.withTintColor(#colorLiteral(red: 0.2470588235, green: 0.6, blue: 0.1607843137, alpha: 1))
			.withConfiguration(UIImage.SymbolConfiguration(scale: .large))
		return self.imageFactory.make(image: icon)
	}()

	init(
		map: Map,
		mainMapEnergyConsumption: IEnergyConsumption,
		miniMapEnergyConsumption: IEnergyConsumption? = nil,
		trafficRouter: TrafficRouter,
		navigationManager: NavigationManager,
		locationService: ILocationService,
		voiceManager: VoiceManager,
		applicationIdleTimerService: IApplicationIdleTimerService,
		navigatorSettings: INavigatorSettings,
		mapSourceFactory: IMapSourceFactory,
		settingsService: ISettingsService,
		logger: ILogger,
		imageFactory: IImageFactory
	) throws {
		self.map = map
		self.mainMapEnergyConsumption = mainMapEnergyConsumption
		self.miniMapEnergyConsumption = miniMapEnergyConsumption
		self.trafficRouter = trafficRouter
		self.navigationManager = navigationManager
		self.locationService = locationService
		self.voiceManager = voiceManager
		self.applicationIdleTimerService = applicationIdleTimerService
		self.logger = logger
		self.settingsService = settingsService
		self.imageFactory = imageFactory
		self.isMiniMapSelected = settingsService.isMiniMapSelected
		let styleZoomFollowControllerType = Constants.defaultStyleZoomFollowControllerType
		self.styleZoomFollowControllerType = styleZoomFollowControllerType
		self.navigatorSettingsViewModel = NavigatorSettingsViewModel(
			voiceManager: voiceManager,
			navigatorSettings: navigatorSettings,
			styleZoomFollowControllerType: styleZoomFollowControllerType,
			betterRouteSettings: navigationManager.makeBetterRouteSettings(),
			freeRoamSettings: navigationManager.makeFreeRoamSettings()
		)

		self.styleZoomFollowControllerTypeCancellable = self.navigatorSettingsViewModel.$styleZoomFollowControllerType
			.receive(on: DispatchQueue.main)
			.sink {
				[weak self] type in
				self?.styleZoomFollowControllerType = type
			}

		self.updateNavigatorVoice(self.navigatorSettingsViewModel.currentVoice)
		self.voiceChangedCancellable = self.navigatorSettingsViewModel.$currentVoice
			.receive(on: DispatchQueue.main)
			.sink {
				[weak self] voice in
				self?.updateNavigatorVoice(voice)
			}

		let locationSource = mapSourceFactory.makeMyLocationMapObjectSource(
			bearingSource: .satellite
		)
		self.map.addSource(source: locationSource)
		if settingsService.addRoadEventSourceInNavigationView {
			self.map.addSource(source: mapSourceFactory.makeRoadEventSource())
		}
		self.setupCamera()
		self.cameraStateCancellable = self.map.camera.sinkOnStatefulChangesOnMainThread(reason: .state) { [weak self] (state: CameraState) in
			Task { @MainActor [weak self] in
				guard let self else { return }
				self.handleStateChange(state: state)
			}
		}
	}

	func tap(_ objectInfo: RenderedObjectInfo) {
		self.touchHandle(objectInfo, touchType: .tap)
	}

	func longPress(_ objectInfo: RenderedObjectInfo) {
		self.touchHandle(objectInfo, touchType: .longPress)
	}

	@MainActor
	func startNavigation() {
		guard self.isTargetPointSearchInProgress else { return }
		self.state = .routeSearch
		let options = self.navigatorSettingsViewModel.navigatorOptions
		self.getCurrentPosition { [weak self] coordinate in
			guard let coordinate else {
				self?.errorMessage = "We can't find you:("
				self?.stopNavigation()
				return
			}

			guard let cameraPosition = self?.map.camera.position.point else {
				return
			}

			let targetPoint = RouteSearchPoint(coordinates: cameraPosition)
			self?.startNavigation(
				with: options,
				currentLocation: coordinate,
				targetPoint: targetPoint
			)
		}
	}

	func stopNavigation() {
		self.applicationIdleTimerService.isIdleTimerDisabled = false
		self.routeSearchCancellable?.cancel()
		self.routeSearchCancellable = nil
		if self.navigationManager.uiModel.isFreeRoam {
			self.navigationManager.stop()
			self.state = .targetPointSearch
			self.styleZoomFollowControllerType = .default
		} else {
			self.startFreeRoamNavigation()
		}
	}

	func restoreNavigation() {
		let options = self.navigatorSettingsViewModel.navigatorOptions
		guard options.mode != .freeRoam else {
			self.startFreeRoamNavigation()
			return
		}

		guard let navigationState = self.navigatorSettingsViewModel.navigationState,
		      let targetPoint = navigationState.finishPoint
		else {
			return
		}

		self.startNavigation(
			route: navigationState.trafficRoute,
			targetPoint: targetPoint,
			simulation: options.mode == .simulation,
			simulationSpeedKmH: options.simulationSpeedKmH,
			routeSearchOptions: navigationState.routeSearchOptions
		)
	}

	func select(route: TrafficRoute) {
		guard case let .routeSelection(targetPoint, options) = self.state else {
			return
		}
		self.startNavigation(
			route: route,
			targetPoint: targetPoint,
			simulation: options.mode == .simulation,
			simulationSpeedKmH: options.simulationSpeedKmH
		)
	}

	func addIntermediatePoint(routePoint: RouteSearchPoint) {
		self.mapObjectManager.removeAll()
		guard case .navigation = self.state else {
			self.intermediatePoints.append(routePoint)
			return
		}

		if self.navigationManager.uiModel.isFreeRoam {
			self.getCurrentPosition { [weak self] coordinate in
				guard let coordinate else {
					self?.errorMessage = "We can't find you:("
					return
				}

				self?.startNavigation(targetPoint: routePoint, currentLocation: coordinate)
			}
			return
		}

		self.rebuildTrafficRoute(routePoint: routePoint)
	}

	func cancelAddIntermediatePoint() {
		self.mapObjectManager.removeAll()
	}

	private func startFreeRoamNavigation() {
		self.state = .navigation
		do {
			try self.navigationManager.start()
		} catch let error as SimpleError {
			self.errorMessage = error.description
		} catch {
			self.errorMessage = error.localizedDescription
		}
	}

	private func handleStateChange(state: CameraState) {
		switch state {
		case .free:
			self.mainMapEnergyConsumption.maxFps = 30
			self.mainMapEnergyConsumption.powerSavingMaxFps = 20
			self.miniMapEnergyConsumption?.maxFps = 20
			self.miniMapEnergyConsumption?.powerSavingMaxFps = 10
		default:
			self.mainMapEnergyConsumption.maxFps = UIScreen.main.maximumFramesPerSecond
			self.mainMapEnergyConsumption.powerSavingMaxFps = UIScreen.main.maximumFramesPerSecond / 2
			self.miniMapEnergyConsumption?.maxFps = 20
			self.miniMapEnergyConsumption?.powerSavingMaxFps = 10
		}
	}

	private func searchRoute(
		to targetPoint: RouteSearchPoint,
		currentLocation: CLLocationCoordinate2D,
		completion: @escaping @Sendable (Result<[TrafficRoute], Error>) -> Void
	) {
		let routeSearchOptions = self.navigatorSettingsViewModel.routeType.routeSearchOptions
		self.routeSearchCancellable?.cancel()
		self.routeSearchCancellable = self.trafficRouter.findRoute(
			startPoint: RouteSearchPoint(coordinates: GeoPoint(coordinate: currentLocation)),
			finishPoint: targetPoint,
			routeSearchOptions: routeSearchOptions,
			intermediatePoints: self.intermediatePoints
		).sinkOnMainThread { routes in
			completion(.success(routes))
		} failure: { error in
			completion(.failure(error))
		}
		self.intermediatePoints.removeAll()
	}

	private func searchRoute(
		currentLocation: CLLocationCoordinate2D,
		options: NavigatorOptions,
		finishPoint: RouteSearchPoint
	) {
		self.getRenderedObjectsCancellable?.cancel()
		guard
			let screenPoint = self.map.camera.projection.mapToScreen(point: finishPoint.coordinates)
		else {
			return
		}

		self.getRenderedObjectsCancellable = self.map.getRenderedObjects(
			centerPoint: screenPoint,
			radius: Constants.tapRadius
		).sinkOnMainThread { [weak self] infos in
			guard
				let objectInfo = infos.first(where: { $0.item.item is DgisMapObject })?.item,
				let mapObject = objectInfo.item as? DgisMapObject
			else {
				return
			}

			let targetPoint = RouteSearchPoint(
				coordinates: finishPoint.coordinates,
				course: nil,
				objectId: mapObject.id,
				levelId: objectInfo.levelId
			)
			Task { @MainActor [weak self] in
				self?.searchRoute(to: targetPoint, currentLocation: currentLocation) { [weak self] result in
					Task { @MainActor [weak self] in
						self?.handle(routeSearchResult: result, targetPoint: targetPoint, options: options)
					}
				}
			}
		} failure: { _ in
		}
	}

	private func startNavigation(
		with options: NavigatorOptions,
		currentLocation: CLLocationCoordinate2D,
		targetPoint: RouteSearchPoint
	) {
		self.applicationIdleTimerService.isIdleTimerDisabled = true
		self.navigationManager.exceedSpeedLimitSettings.allowableSpeedExcess = options.allowableSpeedExcessKmH * Float(Constants.kmhToMs)
		self.navigationManager.apply(self.navigatorSettingsViewModel.betterRouteSettings)
		self.navigationManager.apply(self.navigatorSettingsViewModel.freeRoamSettings)
		switch options.mode {
		case .freeRoam:
			self.startFreeRoamNavigation()
		case .default, .simulation:
			self.searchRoute(
				currentLocation: currentLocation,
				options: options,
				finishPoint: targetPoint
			)
		}
	}

	private func startNavigation(
		targetPoint: RouteSearchPoint,
		currentLocation: CLLocationCoordinate2D
	) {
		let options = NavigatorOptions(
			mode: .default,
			simulationSpeedKmH: self.navigatorSettingsViewModel.simulationSpeedKmH,
			allowableSpeedExcessKmH: self.navigatorSettingsViewModel.maxAllowableSpeedExcessKmH
		)
		self.navigatorSettingsViewModel.isSimulation = false
		self.navigatorSettingsViewModel.isFreeRoam = false
		self.startNavigation(with: options, currentLocation: currentLocation, targetPoint: targetPoint)
	}

	private func handle(
		routeSearchResult: Result<[TrafficRoute], Error>,
		targetPoint: RouteSearchPoint,
		options: NavigatorOptions
	) {
		switch routeSearchResult {
		case let .success(routes):
			if routes.isEmpty {
				self.handle(routeSearchError: "Route not found.")
			} else if routes.count > 1 {
				self.request = .routeSelection(routes)
				self.state = .routeSelection(targetPoint, options)
			} else {
				self.startNavigation(
					route: routes[0],
					targetPoint: targetPoint,
					simulation: options.mode == .simulation,
					simulationSpeedKmH: options.simulationSpeedKmH
				)
			}
		case let .failure(error):
			self.handle(routeSearchError: error.localizedDescription)
		}
	}

	private func handle(routeSearchError: String) {
		self.errorMessage = routeSearchError
		self.stopNavigation()
	}

	private func startNavigation(
		route: TrafficRoute,
		targetPoint: RouteSearchPoint,
		simulation: Bool,
		simulationSpeedKmH: Double,
		routeSearchOptions: RouteSearchOptions? = nil
	) {
		self.state = .navigation
		let routeSearchOptions = routeSearchOptions ?? self.navigatorSettingsViewModel.routeType.routeSearchOptions
		do {
			if simulation {
				let simulationSpeed = SimulationConstantSpeed(speed: simulationSpeedKmH * Constants.kmhToMs)
				self.navigationManager.simulationSettings.speedMode = .speed(simulationSpeed)
				try self.navigationManager.startSimulation(
					routeBuildOptions: RouteBuildOptions(finishPoint: targetPoint, routeSearchOptions: routeSearchOptions),
					trafficRoute: route
				)
			} else {
				try self.navigationManager.start(
					routeBuildOptions: RouteBuildOptions(finishPoint: targetPoint, routeSearchOptions: routeSearchOptions),
					trafficRoute: route
				)
			}
		} catch let error as SimpleError {
			self.handle(routeSearchError: error.description)
		} catch {
			self.handle(routeSearchError: error.localizedDescription)
		}
	}

	private func updateNavigatorVoice(_ voice: Voice?) {
		self.navigationManager.voiceSelector.voice = voice?.navigationVoice
	}

	private func setupCamera() {
		let cameraPosition = self.map.camera.position
		let initialStyleZoom = projectionZToStyleZ(projectionZ: cameraPosition.zoom, latitude: cameraPosition.point.latitude)
		self.styleZoomFollowController.setStyleZoom(styleZoom: initialStyleZoom)
	}

	private func getCurrentPosition(completion: @escaping (CLLocationCoordinate2D?) -> Void) {
		self.locationService.getCurrentPosition { coordinate in
			DispatchQueue.main.async {
				completion(coordinate)
			}
		}
	}

	private func startStyleZoomVariation() {
		self.map.camera.setCustomFollowController(followController: self.styleZoomFollowController)
		guard self.styleZoomAnimator == nil else { return }

		self.styleZoomAnimator = ValueAnimator(
			from: 0,
			to: Constants.maxStyleZoom - Constants.minStyleZoom,
			duration: Constants.animationDuration,
			animationCurveFunction: { time, _ in
				abs(sin(time))
			},
			valueUpdater: { value in
				let currentStyleZoom = Constants.minStyleZoom + value
				Task { @MainActor [weak self] in
					self?.styleZoomFollowController.setStyleZoom(styleZoom: StyleZoom(value: Float(currentStyleZoom)))
				}
			}
		)
		self.styleZoomAnimator?.start()
	}

	private func stopStyleZoomVariation() {
		self.map.camera.removeCustomFollowController()
		self.styleZoomAnimator?.cancel()
		self.styleZoomAnimator = nil
	}

	private func touchHandle(_ objectInfo: RenderedObjectInfo, touchType: TouchType) {
		self.getRenderedObjectsCancellable?.cancel()
		let tapPoint = objectInfo.closestViewportPoint
		let cancel = self.map.getRenderedObjects(centerPoint: tapPoint, radius: ScreenDistance(value: 5)).sinkOnMainThread(
			receiveValue: { [weak self] infos in
				Task { @MainActor [weak self] in
					var roadEvent: RoadEvent?
					var alternativeRoute: TrafficRoute?
					for info in infos {
						if roadEvent == nil, info.item.item is RoadEventMapObject {
							roadEvent = (info.item.item as? RoadEventMapObject)?.event
						} else if alternativeRoute == nil, info.item.item is RouteMapObject {
							alternativeRoute = (info.item.item as! RouteMapObject).isActive ? nil : (info.item.item as! RouteMapObject).route
						}
						if roadEvent != nil, alternativeRoute != nil {
							break
						}
					}
					switch touchType {
					case .tap:
						if let alternativeRoute {
							self?.navigationManager.alternativeRouteSelector.selectAlternativeRoute(trafficRoute: alternativeRoute)
						} else if let roadEvent {
							self?.roadEventCardPresenterCallback?(roadEvent)
						}
					case .longPress:
						guard
							roadEvent == nil,
							let renderObject = infos.first,
							let dgisObject = renderObject.item.item as? DgisMapObject,
							let self
						else {
							return
						}

						let mapPoint = renderObject.closestMapPoint
						let markerOptions = MarkerOptions(
							position: mapPoint,
							icon: self.intermediatePointMarkerIcon
						)
						do {
							let marker = try Marker(options: markerOptions)
							self.mapObjectManager.addObject(item: marker)
						} catch let error as SimpleError {
							self.errorMessage = error.description
						} catch {
							self.errorMessage = error.localizedDescription
						}

						let routePoint = RouteSearchPoint(
							coordinates: mapPoint.point,
							objectId: dgisObject.id
						)
						self.request = .addIntermediatePoint(routePoint)
					}
				}
			},
			failure: { [weak self] error in
				Task { @MainActor [weak self] in
					self?.logger.error("Failed to fetch objects: \(error)")
				}
			}
		)
		self.getRenderedObjectsCancellable = cancel
	}

	private func rebuildTrafficRoute(routePoint: RouteSearchPoint) {
		guard
			let routePosition = self.navigatorModel.routePosition,
			let routePositionPoint = self.navigatorModel.route.route.geometry.calculateGeoPoint(routePoint: routePosition)?.point,
			let targetPoint = self.navigatorModel.route.routeBuildOptions?.finishPoint
		else {
			return
		}

		self.intermediatePoints.removeAll()
		let intermediatePoints = self.navigatorModel.route.route.intermediatePoints
		if intermediatePoints.entries.count > 0,
		   let intermediatePointEntry = intermediatePoints.findNearForward(point: routePosition),
		   let index = intermediatePoints.entries.firstIndex(of: intermediatePointEntry)
		{
			for itemIndex in index ..< intermediatePoints.entries.count {
				self.intermediatePoints.append(RouteSearchPoint(coordinates: intermediatePoints.entries[itemIndex].value))
			}
		}
		self.intermediatePoints.append(routePoint)

		let currentLocation = CLLocationCoordinate2D(
			latitude: routePositionPoint.latitude.value,
			longitude: routePositionPoint.longitude.value
		)
		self.searchRoute(to: targetPoint, currentLocation: currentLocation) { [weak self] result in
			Task { @MainActor [weak self] in
				guard let self else { return }
				self.handle(
					routeSearchResult: result,
					targetPoint: targetPoint,
					options: self.navigatorSettingsViewModel.navigatorOptions
				)
			}
		}
	}
}

private extension NavigationManager {
	func makeBetterRouteSettings() -> NavigatorBetterRouteSettings {
		NavigatorBetterRouteSettings(
			betterRouteTimeCostThreshold: self.alternativeRoutesProviderSettings.betterRouteTimeCostThreshold,
			betterRouteLengthThreshold: self.alternativeRoutesProviderSettings.betterRouteLengthThreshold,
			routeSearchDefaultDelay: self.alternativeRoutesProviderSettings.routeSearchDelay
		)
	}

	func apply(_ settings: NavigatorBetterRouteSettings) {
		self.alternativeRoutesProviderSettings.betterRouteTimeCostThreshold = settings.betterRouteTimeCostThreshold
		self.alternativeRoutesProviderSettings.betterRouteLengthThreshold = settings.betterRouteLengthThreshold
		self.alternativeRoutesProviderSettings.routeSearchDelay = settings.routeSearchDefaultDelay
	}
}

private extension NavigationManager {
	func makeFreeRoamSettings() -> FreeRoamSettings {
		FreeRoamSettings(
			cacheDistanceOnRoute: self.freeRoamSettings.onRoutePrefetchLength,
			cacheRadiusOnRoute: self.freeRoamSettings.onRoutePrefetchRadiusMeters,
			cacheRadiusInFreeRoam: self.freeRoamSettings.prefetchRadiusMeters
		)
	}

	func apply(_ settings: FreeRoamSettings) {
		self.freeRoamSettings.onRoutePrefetchLength = settings.cacheDistanceOnRoute
		self.freeRoamSettings.onRoutePrefetchRadiusMeters = settings.cacheRadiusOnRoute
		self.freeRoamSettings.prefetchRadiusMeters = settings.cacheRadiusInFreeRoam
	}
}
