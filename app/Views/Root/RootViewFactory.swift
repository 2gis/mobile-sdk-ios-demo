import SwiftUI
import DGis

struct RootViewFactory {
	private let sdk: DGis.Container
	private let locationManagerFactory: () -> LocationService
	private let settingsService: ISettingsService
	private let mapProvider: IMapProvider
	private let applicationIdleTimerService: IApplicationIdleTimerService
	private let navigatorSettings: INavigatorSettings

	init(
		sdk: DGis.Container,
		locationManagerFactory: @escaping () -> LocationService,
		settingsService: ISettingsService,
		mapProvider: IMapProvider,
		applicationIdleTimerService: IApplicationIdleTimerService,
		navigatorSettings: INavigatorSettings
	) {
		self.sdk = sdk
		self.locationManagerFactory = locationManagerFactory
		self.settingsService = settingsService
		self.mapProvider = mapProvider
		self.applicationIdleTimerService = applicationIdleTimerService
		self.navigatorSettings = navigatorSettings
	}

	@ViewBuilder
	func makeDemoPageView(_ page: DemoPage) -> some View {
		switch page {
			case .camera:
				self.makeCameraDemoPage()
			case .customMapControls:
				self.makeCustomMapControlsDemoPage()
			case .mapObjectsIdentification:
				self.makeMapObjectsIdentificationDemoPage()
			case .markers:
				self.makeMarkersDemoPage()
			case .dictionarySearch:
				self.makeSearchStylesDemoPage()
			case .mapStyles:
				self.makeCustomStylesDemoPage()
			case .visibleAreaDetection:
				self.makeVisibleAreaDetectionDemoPage()
			case .mapTheme:
				self.makeMapThemeDemoPage()
			case .fps:
				self.makeFpsDemoPage()
			case .clustering:
				self.makeClusteringDemoPage()
			case .customGestures:
				self.makeCustomGesturesDemoPage()
			case .territoryManager:
				self.makeTerritoryManagerDemoView()
			case .routeSearch:
				self.makeRouteSearchDemoPage()
			case .navigator:
				self.makeNavigatorDemoPage()
		}
	}

	private func makeCustomStylesDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = CustomMapStyleDemoViewModel(
			styleFactory: { [sdk = self.sdk] in
				sdk.makeStyleFactory()
			},
			map: mapFactory.map
		)
		return CustomMapStyleDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeSearchStylesDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = SearchDemoViewModel(
			searchManagerFactory: { [sdk = self.sdk] in
				SearchManager.createOnlineManager(context: sdk.context)
			},
			map: mapFactory.map
		)
		return SearchDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory))
	}

	private func makeCameraDemoPage() -> some View {
		let coordinate = GeoPoint(latitude: 55.759909, longitude: 37.618806)
		let cameraPosition = CameraPosition(point: coordinate, zoom: Zoom(value: 17))
		
		var mapOptions = MapOptions.default
		mapOptions.position = cameraPosition
		mapOptions.deviceDensity = DeviceDensity(value: Float(UIScreen.main.nativeScale))
		let mapFactory = self.makeMapFactory(mapOptions: mapOptions)
		let viewModel = CameraDemoViewModel(
			locationManagerFactory: self.locationManagerFactory,
			map: mapFactory.map,
			sdkContext: self.sdk.context
		)
		return CameraDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeMarkersDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = MarkersDemoViewModel(
			map: mapFactory.map,
			imageFactory: self.sdk.imageFactory
		)
		return MarkersDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeVisibleAreaDetectionDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = VisibleAreaDetectionDemoViewModel(map: mapFactory.map)
		return VisibleAreaDetectionDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeMapObjectsIdentificationDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = MapObjectsIdentificationDemoViewModel(
			searchManagerFactory: self.makeSearchManagerFactory(),
			imageFactory: { [sdk = self.sdk] in
				sdk.imageFactory
			},
			mapMarkerPresenter: self.makeMapMarkerPresenter(),
			map: mapFactory.map,
			mapSourceFactory: MapSourceFactory(context: self.sdk.context)
		)
		return MapObjectsIdentificationDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeCustomMapControlsDemoPage() -> some View {
		let viewModel = CustomMapControlsDemoViewModel()
		return CustomMapControlsDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: self.makeMapFactory())
		)
	}

	private func makeMapThemeDemoPage() -> some View {
		let viewModel = MapThemeDemoViewModel()
		return MapThemeDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: self.makeMapFactory())
		)
	}

	private func makeFpsDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = FpsDemoViewModel(
			map: mapFactory.map,
			energyConsumption: mapFactory.energyConsumption
		)
		return FpsDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeClusteringDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = ClusteringDemoViewModel(
			map: mapFactory.map,
			imageFactory: self.sdk.imageFactory
		)
		return ClusteringDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeCustomGesturesDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = CustomGesturesDemoViewModel(mapGesturesType: .custom)
		return CustomGesturesDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeTerritoryManagerDemoView() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = TerritoryManagerDemoViewModel(
			packageManager: getPackageManager(context: self.sdk.context),
			territoryManager: getTerritoryManager(context: self.sdk.context)
		)
		return TerritoryManagerDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeRouteSearchDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = RouteSearchDemoViewModel(
			map: mapFactory.map,
			mapSourceFactory: MapSourceFactory(context: self.sdk.context)
		)
		return RouteSearchDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeNavigatorDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = NavigatorDemoViewModel(
			map: mapFactory.map,
			trafficRouter: TrafficRouter(context: self.sdk.context),
			navigationManager: NavigationManager(platformContext: self.sdk.context),
			locationService: self.locationManagerFactory(),
			voiceManager: getVoiceManager(context: self.sdk.context),
			applicationIdleTimerService: self.applicationIdleTimerService,
			navigatorSettings: self.navigatorSettings,
			mapSourceFactory: MapSourceFactory(context: self.sdk.context),
			roadEventCardPresenter: RoadEventCardPresenter(),
			settingsService: self.settingsService,
			imageFactory: { [sdk = self.sdk] in
				sdk.imageFactory
			}
		)
		return NavigatorDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeDemoPageComponentsFactory(mapFactory: IMapFactory) -> DemoPageComponentsFactory {
		DemoPageComponentsFactory(
			sdk: self.sdk,
			mapFactory: mapFactory,
			settingsService: self.settingsService
		)
	}

	private func makeMapFactory(mapOptions: MapOptions = .default) -> IMapFactory {
		try! self.sdk.makeMapFactory(options: mapOptions)
	}

	private func makeSearchManagerFactory() -> (() -> SearchManager) {
		return { [sdk = self.sdk, settingsService = self.settingsService] in
			switch settingsService.mapDataSource {
				case .online:
					return SearchManager.createOnlineManager(context: sdk.context)
				case .hybrid:
					return SearchManager.createSmartManager(context: sdk.context)
				case .offline:
					return SearchManager.createOfflineManager(context: sdk.context)
			}
		}
	}

	private func makeMapMarkerPresenter() -> MapMarkerPresenter {
		MapMarkerPresenter { [sdk = self.sdk] mapMarkerView, position in
			sdk.markerViewFactory.make(
				view: mapMarkerView,
				position: position,
				anchor: Anchor(),
				offsetX: 0.0,
				offsetY: 0.0
			)
		}
	}
}
