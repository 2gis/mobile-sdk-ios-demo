import SwiftUI
import Combine
import CoreLocation
import DGis

final class NavigatorDemoViewModel: ObservableObject {
	private enum Constants {
		static let kmhToMs = 1 / 3.6
		static let initialZoom: Zoom = 17.5
		static let minZoom: Double = 15.0
		static let maxZoom: Double = 18.0
		static let animationDuration = abs(maxZoom - minZoom) * 1000
		static let mapState = "Global/MapStateInNavigator"
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
	private let imageFactory: () -> IImageFactory
	private let zoomFollowController = PlatformZoomFollowController()

	private var routeSearchCancellable: ICancellable?
	private var navigationStateCancellable: ICancellable?
	private var voiceChangedCancellable: AnyCancellable?
	private var getRenderedObjectsCancellable: ICancellable?
	private var zoomFollowControllerTypeCancellable: AnyCancellable?
	private var isVoiceConfigured: Bool = false
	private var intermediatePoints: [RouteSearchPoint] = []
	private lazy var storage: IKeyValueStorage = UserDefaults.standard
	private lazy var mapObjectManager: MapObjectManager = MapObjectManager(map: self.map)
	private lazy var intermediatePointMarkerIcon: DGis.Image = {
		let factory = self.imageFactory()
		let icon = UIImage(systemName: "mappin.and.ellipse")!
			.withTintColor(#colorLiteral(red: 0.2470588235, green: 0.6, blue: 0.1607843137, alpha: 1))
			.withConfiguration(UIImage.SymbolConfiguration(scale: .large))
		return factory.make(image: icon)
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
		imageFactory: @escaping () -> IImageFactory
	) {
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
		self.navigatorSettingsViewModel = NavigatorSettingsViewModel(
			voiceManager: voiceManager,
			navigatorSettings: navigatorSettings,
			freeRoamSettings: navigationManager.makeFreeRoamSettings()
		)

		self.navigationManager.mapManager.addMap(map: self.map)
		self.updateNavigatorVoice(self.navigatorSettingsViewModel.currentVoice)
		self.voiceChangedCancellable = self.navigatorSettingsViewModel.$currentVoice
			.receive(on: DispatchQueue.main)
			.sink {
				[weak self] voice in

				self?.updateNavigatorVoice(voice)
		}

		let locationSource = mapSourceFactory.makeSmoothMyLocationMapObjectSource(
			directionBehaviour: .followSatelliteHeading
		)
		self.map.addSource(source: locationSource)
		if settingsService.addRoadEventSourceInNavigationView {
			self.map.addSource(source: mapSourceFactory.makeRoadEventSource())
		}
		self.setupCamera()
		self.restoreMapState()
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
				self?.errorMessage = "Не можем вас найти:("
				self?.stopNavigation()
				return
			}

			self?.startNavigation(with: options, currentLocation: coordinate)
		}
	}

	func stopNavigation() {
		self.applicationIdleTimerService.isIdleTimerDisabled = false
		self.routeSearchCancellable?.cancel()
		self.routeSearchCancellable = nil
		if self.navigationManager.uiModel.state == .freeRoam {
			self.navigationManager.stop()
			self.state = .targetPointSearch
		} else {
			self.startFreeRoamNavigation()
		}
	}

	func saveState() {
		let mapState = PackedMapState.fromMap(map: self.map)
		self.storage.set(mapState.toBytes().base64EncodedString(), forKey: Constants.mapState)

		self.navigatorSettingsViewModel.saveState(uiModel: self.navigationManager.uiModel)
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

		self.rebuildTrafficRoute(routePoint: routePoint)
	}

	func cancelAddIntermediatePoint() {
		self.mapObjectManager.removeAll()
	}

	private func restoreMapState() {
		guard let rawValue: String = self.storage.value(forKey: Constants.mapState),
			  let storedMapState = Data(base64Encoded: rawValue),
			  let mapState = try? PackedMapState.fromBytes(data: storedMapState) else { return }

		self.map.camera.position = mapState.cameraPosition
	}

	private func startFreeRoamNavigation() {
		self.state = .navigation
		self.navigationManager.start()
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

	private func startNavigation(with options: NavigatorOptions, currentLocation: CLLocationCoordinate2D) {
		self.applicationIdleTimerService.isIdleTimerDisabled = true
		self.navigationManager.exceedSpeedLimitSettings.allowableSpeedExcess = options.allowableSpeedExcessKmH * Float(Constants.kmhToMs)
		self.navigationManager.apply(self.navigatorSettingsViewModel.freeRoamSettings)
		switch options.mode {
			case .freeRoam:
				self.startFreeRoamNavigation()
			case .default, .simulation:
				let targetPoint = RouteSearchPoint(coordinates: self.map.camera.position.point)
				self.searchRoute(to: targetPoint, currentLocation: currentLocation) { [weak self] result in
					self?.handle(routeSearchResult: result, targetPoint: targetPoint, options: options)
				}
		}
	}

	private func handle(
		routeSearchResult: Result<[TrafficRoute], Error>,
		targetPoint: RouteSearchPoint,
		options: NavigatorOptions
	) {
		switch routeSearchResult {
			case .success(let routes):
				if routes.isEmpty {
					self.handle(routeSearchError: "Проезд не найден.")
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
		if simulation {
			let simulationSpeed = SimulationConstantSpeed(speed: simulationSpeedKmH * Constants.kmhToMs)
			self.navigationManager.simulationSettings.speedMode = .speed(simulationSpeed)
			self.navigationManager.startSimulation(
				routeBuildOptions: RouteBuildOptions(finishPoint: targetPoint, routeSearchOptions: routeSearchOptions),
				trafficRoute: route
			)
		} else {
			self.navigationManager.start(
				routeBuildOptions: RouteBuildOptions(finishPoint: targetPoint, routeSearchOptions: routeSearchOptions),
				trafficRoute: route
			)
		}
	}

	private func updateNavigatorVoice(_ voice: Voice?) {
		self.navigationManager.voiceSelector.voice = voice?.navigationVoice
	}

	private func setupCamera() {
		var position = self.map.camera.position
		position.zoom = Constants.initialZoom
		self.map.camera.position = position
		self.map.camera.setBehaviour(behaviour: CameraBehaviour(position: .init(bearing: .satellite, tilt: .off, zoom: .on)))

		self.zoomFollowController.setZoom(zoom: Constants.initialZoom)
	}

	private func getCurrentPosition(completion: @escaping (CLLocationCoordinate2D?) -> ()) {
		self.locationService.getCurrentPosition { coordinate in
			DispatchQueue.main.async {
				completion(coordinate)
			}
		}
	}

	private func touchHandle(_ location: CGPoint, touchType: TouchType) {
		self.getRenderedObjectsCancellable?.cancel()
		let mapLocation = location.applying(self.toMap)
		let tapPoint = ScreenPoint(x: Float(mapLocation.x), y: Float(mapLocation.y))
		let cancel = self.map.getRenderedObjects(centerPoint: tapPoint, radius: ScreenDistance(value: 5)).sinkOnMainThread(
			receiveValue: { [weak self] infos in
				let roadEvent = infos.first(where: { $0.item.item is RoadEventMapObject })?.item.item as? RoadEventMapObject
				switch touchType {
				case .tap:
					guard roadEvent != nil else { return }
					self?.roadEventCardPresenter.showRoadEvent(roadEvent!.event)
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
					let marker = Marker(options: markerOptions)
					self.mapObjectManager.addObject(item: marker)

					let routePoint = RouteSearchPoint(
						coordinates: mapPoint.point,
						objectId: dgisObject.id
					)
					self.request = .addIntermediatePoint(routePoint)
				}
			},
			failure: { error in
				print("Failed to fetch objects: \(error)")
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
