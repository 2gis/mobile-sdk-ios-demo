import SwiftUI
import Combine
import CoreLocation
import DGis

enum StyleZoomFollowControllerType: CaseIterable, PickerViewOption {
	case `default`, custom

	var id: StyleZoomFollowControllerType { self }
	var name: String {
		switch self {
			case .default:
				return "Default"
			case .custom:
				return "Custom"
		}
	}
}

final class NavigatorDemoViewModel: ObservableObject {
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

	@Published var state: State = .targetPointSearch
	@Published var isErrorAlertShown: Bool = false
	@Published var request: RequestType?
	@Published var styleZoomFollowControllerType: StyleZoomFollowControllerType {
		didSet {
			if oldValue != self.styleZoomFollowControllerType {
				switch self.styleZoomFollowControllerType {
					case .default:
						self.stopStyleZoomVariation()
					case .custom:
						self.startStyleZoomVariation()
				}
			}
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
	let roadEventCardPresenter: IRoadEventCardPresenter

	private var isTargetPointSearchInProgress: Bool {
		guard case .targetPointSearch = self.state else { return false }
		return true
	}

	private let map: Map
	private let trafficRouter: TrafficRouter
	private let locationService: LocationService
	private let voiceManager: VoiceManager
	private var applicationIdleTimerService: IApplicationIdleTimerService
	private let toMap: CGAffineTransform
	private let imageFactory: IImageFactory
	private let styleZoomFollowController = PlatformStyleZoomFollowController()

	private var routeSearchCancellable: ICancellable?
	private var navigationStateCancellable: ICancellable?
	private var voiceChangedCancellable: AnyCancellable?
	private var getRenderedObjectsCancellable: ICancellable?
	private var styleZoomFollowControllerTypeCancellable: AnyCancellable?
	private var isVoiceConfigured: Bool = false
	private var styleZoomAnimator: ValueAnimator? = nil
	private var intermediatePoints: [RouteSearchPoint] = []
	private lazy var storage: IKeyValueStorage = UserDefaults.standard
	private lazy var mapObjectManager: MapObjectManager = MapObjectManager(map: self.map)
	private lazy var intermediatePointMarkerIcon: DGis.Image = {
		let icon = UIImage(systemName: "mappin.and.ellipse")!
			.withTintColor(#colorLiteral(red: 0.2470588235, green: 0.6, blue: 0.1607843137, alpha: 1))
			.withConfiguration(UIImage.SymbolConfiguration(scale: .large))
		return self.imageFactory.make(image: icon)
	}()

	init(
		map: Map,
		trafficRouter: TrafficRouter,
		navigationManager: NavigationManager,
		locationService: LocationService,
		voiceManager: VoiceManager,
		applicationIdleTimerService: IApplicationIdleTimerService,
		navigatorSettings: INavigatorSettings,
		mapSourceFactory: IMapSourceFactory,
		roadEventCardPresenter: IRoadEventCardPresenter,
		settingsService: ISettingsService,
		imageFactory: IImageFactory
	) throws {
		self.map = map
		self.trafficRouter = trafficRouter
		self.navigationManager = navigationManager
		self.locationService = locationService
		self.voiceManager = voiceManager
		self.applicationIdleTimerService = applicationIdleTimerService
		self.roadEventCardPresenter = roadEventCardPresenter
		let scale = UIScreen.main.nativeScale
		self.toMap = CGAffineTransform(scaleX: scale, y: scale)
		self.imageFactory = imageFactory
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

		let locationSource = mapSourceFactory.makeMyLocationMapObjectSource()
		self.map.addSource(source: locationSource)
		if settingsService.addRoadEventSourceInNavigationView {
			self.map.addSource(source: mapSourceFactory.makeRoadEventSource())
		}
		self.setupCamera()
	}

	func tap(_ location: CGPoint) {
		self.touchHandle(location, touchType: .tap)
	}

	func longPress(_ location: CGPoint) {
		self.touchHandle(location, touchType: .longPress)
	}

	func startNavigation() {
		guard self.isTargetPointSearchInProgress else { return }
		self.state = .routeSearch
		let options = self.navigatorSettingsViewModel.navigatorOptions
		self.getCurrentPosition { [weak self] coordinate in
			guard let coordinate = coordinate else {
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
				guard let coordinate = coordinate else {
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

	private func searchRoute(
		to targetPoint: RouteSearchPoint,
		currentLocation: CLLocationCoordinate2D,
		completion: @escaping (Result<[TrafficRoute], Error>) -> Void
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
			self?.searchRoute(to: targetPoint, currentLocation: currentLocation) { [weak self] result in
				self?.handle(routeSearchResult: result, targetPoint: targetPoint, options: options)
			}
		} failure: { _ in
			return
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
			case .success(let routes):
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
			case .failure(let error):
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

	private func getCurrentPosition(completion: @escaping (CLLocationCoordinate2D?) -> ()) {
		self.locationService.getCurrentPosition { coordinate in
			DispatchQueue.main.async {
				completion(coordinate)
			}
		}
	}

	private func startStyleZoomVariation() {
		self.map.camera.setCustomFollowController(followController: styleZoomFollowController)
		guard self.styleZoomAnimator == nil else { return }

		self.styleZoomAnimator = ValueAnimator(
			from: 0,
			to: Constants.maxStyleZoom - Constants.minStyleZoom,
			duration: Constants.animationDuration,
			animationCurveFunction: { time, duration in
				return abs(sin(time))
			},
			valueUpdater: { value in
				let currentStyleZoom = Constants.minStyleZoom + value
				self.styleZoomFollowController.setStyleZoom(styleZoom: StyleZoom(value: Float(currentStyleZoom)))
			}
		)
		self.styleZoomAnimator?.start()
	}

	private func stopStyleZoomVariation() {
		self.map.camera.removeCustomFollowController()
		self.styleZoomAnimator?.cancel()
		self.styleZoomAnimator = nil
	}

	private func touchHandle(_ location: CGPoint, touchType: TouchType) {
		self.getRenderedObjectsCancellable?.cancel()
		let mapLocation = location.applying(self.toMap)
		let tapPoint = ScreenPoint(x: Float(mapLocation.x), y: Float(mapLocation.y))
		let cancel = self.map.getRenderedObjects(centerPoint: tapPoint, radius: ScreenDistance(value: 5)).sinkOnMainThread(
			receiveValue: { [weak self] infos in
				var roadEvent: RoadEvent? = nil
				var alternativeRoute: TrafficRoute? = nil
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
					if alternativeRoute != nil {
						self?.navigationManager.alternativeRouteSelector.selectAlternativeRoute(trafficRoute: alternativeRoute!)
					} else if roadEvent != nil {
						self?.roadEventCardPresenter.showRoadEvent(roadEvent!)
					}
				case .longPress:
					guard
						roadEvent == nil,
						let renderObject = infos.first,
						let dgisObject = renderObject.item.item as? DgisMapObject,
						let self = self
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
			},
			failure: { [weak self] error in
				self?.errorMessage = "Failed to fetch objects: \(error)"
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
		   let index = intermediatePoints.entries.firstIndex(of: intermediatePointEntry) {
			for itemIndex in index..<intermediatePoints.entries.count {
				self.intermediatePoints.append(RouteSearchPoint(coordinates: intermediatePoints.entries[itemIndex].value))
			}
		}
		self.intermediatePoints.append(routePoint)

		let currentLocation = CLLocationCoordinate2D(
			latitude: routePositionPoint.latitude.value,
			longitude: routePositionPoint.longitude.value
		)
		self.searchRoute(to: targetPoint, currentLocation: currentLocation) { [weak self] result in
			guard let self = self else { return }
			self.handle(
				routeSearchResult: result,
				targetPoint: targetPoint,
				options: self.navigatorSettingsViewModel.navigatorOptions
			)
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
