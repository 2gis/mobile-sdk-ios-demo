import SwiftUI
import DGis

struct RootViewFactory {
	private let sdk: DGis.Container
	private let context: Context
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
	) throws {
		self.sdk = sdk
		self.context = try sdk.context
		self.locationManagerFactory = locationManagerFactory
		self.settingsService = settingsService
		self.mapProvider = mapProvider
		self.applicationIdleTimerService = applicationIdleTimerService
		self.navigatorSettings = navigatorSettings
	}

	@ViewBuilder
	func makeDemoPageView(_ page: DemoPage) throws -> some View {
		switch page {
			case .camera:
				self.makeCameraDemoPage()
			case .customMapControls:
				self.makeCustomMapControlsDemoPage()
			case .mapObjectsIdentification:
				try self.makeMapObjectsIdentificationDemoPage()
			case .markers:
				self.makeMarkersDemoPage()
			case .dictionarySearch:
				try self.makeSearchStylesDemoPage()
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
				try self.makeNavigatorDemoPage()
		}
	}

	private func makeCustomStylesDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = CustomMapStyleDemoViewModel(
			styleFactory: self.makeStyleFactory(),
			map: mapFactory.map
		)
		return CustomMapStyleDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeSearchStylesDemoPage() throws -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = try SearchDemoViewModel(
			searchManager: self.makeSearchManager(),
			map: mapFactory.map,
			locationService: self.sdk.locationService
		)
		return SearchDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeCameraDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = CameraDemoViewModel(
			locationManagerFactory: self.locationManagerFactory,
			map: mapFactory.map,
			mapSourceFactory: MapSourceFactory(context: self.context)
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
			imageFactory: self.makeImageFactory()
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

	private func makeMapObjectsIdentificationDemoPage() throws -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = try MapObjectsIdentificationDemoViewModel(
			searchManager: self.makeSearchManager(),
			imageFactory: self.makeImageFactory(),
			mapMarkerPresenter: self.makeMapMarkerPresenter(),
			map: mapFactory.map,
			mapSourceFactory: MapSourceFactory(context: self.context)
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
			imageFactory: self.makeImageFactory()
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
			packageManager: getPackageManager(context: self.context),
			territoryManager: getTerritoryManager(context: self.context)
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
			mapSourceFactory: MapSourceFactory(context: self.context)
		)
		return RouteSearchDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeNavigatorDemoPage() throws -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = try NavigatorDemoViewModel(
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
			imageFactory: self.makeImageFactory()
		)
		return NavigatorDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeDemoPageComponentsFactory(mapFactory: IMapFactory) -> DemoPageComponentsFactory {
		DemoPageComponentsFactory(
			sdk: self.sdk,
			context: self.context,
			mapFactory: mapFactory,
			settingsService: self.settingsService
		)
	}

	private func makeMapFactory() -> IMapFactory {
		var options = MapOptions.default
		options.sourceDescriptors = [self.settingsService.mapDataSource.sourceDescriptor]
		do {
			return try self.sdk.makeMapFactory(options: options)
		} catch let error as SimpleError {
			let errorMessage = "IMapFactory initialization error: \(error.description)"
			fatalError(errorMessage)
		} catch {
			let errorMessage = "IMapFactory initialization error: \(error)"
			fatalError(errorMessage)
		}
	}

	private func makeStyleFactory() -> IStyleFactory {
		do {
			return try self.sdk.makeStyleFactory()
		} catch let error as SimpleError {
			let errorMessage = "IStyleFactory initialization error: \(error.description)"
			fatalError(errorMessage)
		} catch {
			let errorMessage = "IStyleFactory initialization error: \(error)"
			fatalError(errorMessage)
		}
	}

	private func makeImageFactory() -> IImageFactory {
		do {
			return try self.sdk.makeImageFactory()
		} catch let error as SimpleError {
			let errorMessage = "IImageFactory initialization error: \(error.description)"
			fatalError(errorMessage)
		} catch {
			let errorMessage = "IImageFactory initialization error: \(error)"
			fatalError(errorMessage)
		}
	}

	private func makeSearchManager() throws -> SearchManager {
		switch settingsService.mapDataSource {
			case .online:
				return try SearchManager.createOnlineManager(context: self.context)
			case .hybrid:
				return try SearchManager.createSmartManager(context: self.context)
			case .offline:
				return try SearchManager.createOfflineManager(context: self.context)
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

	private func makeRoadEventCardViewFactory() -> IRoadEventCardViewFactory {
		do {
			return try self.sdk.makeRoadEventCardViewFactory()
		} catch let error as SimpleError {
			let errorMessage = "IRoadEventCardViewFactory initialization error: \(error.description)"
			fatalError(errorMessage)
		} catch {
			let errorMessage = "IRoadEventCardViewFactory initialization error: \(error)"
			fatalError(errorMessage)
		}
	}
}

private extension MapDataSource {
	var sourceDescriptor: MapOptions.SourceDescriptor {
		switch self {
			case .online:
				return .dgisOnlineSource
			case .hybrid:
				return .dgisHybridSource
			case .offline:
				return .dgisOfflineSource
		}
	}
}
