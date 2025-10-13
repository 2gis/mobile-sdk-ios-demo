import DGis
import SwiftUI

final class SwiftUIDemoFactory: RootViewFactory {
	@ViewBuilder
	func makeDemoPageView(_ page: DemoPage) throws -> some View {
		switch page {
		case .benchmark:
			try self.makeBenchmarkDemoPage()
		case .cache:
			try self.makeCacheDemoPage()
		case .cameraCalcPosition:
			try self.makeCalcPositionDemoPage()
		case .cameraMoves:
			try self.makeCameraMovesDemoPage()
		case .cameraRestrictions:
			try self.makeCameraRestrictionsDemoPage()
		case .clustering:
			try self.makeClusteringDemoPage()
		case .copyrightSettings:
			try self.makeCopyrightDemoPage()
		case .customGestures:
			try self.makeCustomGesturesDemoPage()
		case .customMapControls:
			try self.makeCustomMapControlsDemoPage()
		case .directorySearch:
			try self.makeDirectorySearchDemoPage()
		case .fpsRestrictions:
			try self.makeFpsRestrictionsDemoPage()
		case .graphicsOptions:
			try self.makeGraphicsOptionsDemoPage()
		case .locale:
			try self.makeLocaleDemoPage()
		case .mapControls:
			try self.makeMapControlsDemoPage()
		case .mapInteraction:
			try self.makeMapInteractionDemoPage()
		case .mapObjects:
			try self.makeMapObjectsDemoPage()
		case .mapSnapshot:
			try self.makeMapSnapshotDemoPage()
		case .mapTheme:
			try self.makeMapThemeDemoPage()
		case .mapViewMarkers:
			try self.makeMapViewMarkersDemoPage()
		case .multiViewPorts:
			try self.makeMultiViewPortsDemoPage()
		case .parkings:
			try self.makeParkingsDemoPage()
		case .rasterTiles:
			try self.makeRasterTilesDemoPage()
		case .roadEvents:
			try self.makeRoadEventsDemoPage()
		case .staticMaps:
			try self.makeStaticMapsDemoPage()
		case .trafficContol:
			try self.makeTrafficControlDemoPage()
		case .visibleAreaDetection:
			try self.makeVisibleAreaDetectionDemoPage()
		case .visibleRectVisibleArea:
			try self.makeVisibleRectVisibleAreaDemoPage()
		case .minimap:
			try self.makeMiniMapDemoPage()
		case .navigator:
			try self.makeNavigatorViewDemoPage()
		case .navigatorWithMiniMap:
			try self.makeNavigatorWithMiniMapViewDemoPage()
		case .territoryManager:
			try self.makeTerritoryManagerDemoView()
		case .routeEditor:
			try self.makeRouteSearchDemoPage()
		default: Text("Unsupported demo page")
		}
	}

	private func makeBenchmarkDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = try BenchmarkViewModel(
			map: mapFactory.map,
			geometryMapObjectSource: self.makeGeometrySource(),
			energyConsumption: mapFactory.energyConsumption,
			imageFactory: self.makeImageFactory(),
			logger: self.logger
		)
		return BenchmarkView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeCacheDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = try CacheDemoViewModel(
			map: mapFactory.map,
			cacheManager: self.makeHttpCacheManager()
		)
		return CacheDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeCameraMovesDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = CameraMovesDemoViewModel(
			locationManagerFactory: self.locationManagerFactory,
			map: mapFactory.map,
			logger: self.logger,
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService)
		)
		return CameraMovesDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeCalcPositionDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = CalcPositionDemoViewModel(
			map: mapFactory.map,
			logger: self.logger,
			imageFactory: self.makeImageFactory()
		)
		return CalcPositionDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeCameraRestrictionsDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = CameraRestrictionsDemoViewModel(
			map: mapFactory.map,
			logger: self.logger,
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService)
		)
		return CameraRestrictionsDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeClusteringDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = ClusteringDemoViewModel(
			map: mapFactory.map,
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService),
			imageFactory: self.makeImageFactory(),
			modelFactory: self.makeModelFactory(),
			logger: self.logger
		)
		return ClusteringDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeCopyrightDemoPage() throws -> some View {
		try CopyrightSettingsDemoView(
			viewModel: CopyrightSettingsDemoViewModel(),
			mapFactory: self.makeMapFactory()
		)
	}

	private func makeCustomGesturesDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let customGestureViewFactory = CustomGestureViewFactory()
		let mapEventProcessor = DemoMapEventProcessor(processor: mapFactory.mapEventProcessor)
		let gestureView = customGestureViewFactory.makeGestureView(
			map: mapFactory.map,
			eventProcessor: mapEventProcessor,
			coordinateSpace: mapFactory.mapCoordinateSpace
		)
		let viewModel = MapCustomGesturesDemoViewModel(
			map: mapFactory.map,
			mapEventProcessor: mapEventProcessor
		)
		return MapCustomGesturesDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory,
			gestureView: gestureView
		)
	}

	private func makeCustomMapControlsDemoPage() throws -> some View {
		let viewModel = CustomMapControlsDemoViewModel()
		let mapFactory = try self.makeMapFactory()
		return CustomMapViewsDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeDirectorySearchDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = try SearchDemoViewModel(
			searchManager: self.makeSearchManager(),
			map: mapFactory.map,
			imageFactory: self.sdk.imageFactory,
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService),
			locationService: self.sdk.locationService,
			logger: self.logger,
			searchHistory: self.makeSearchHistory()
		)
		return try SearchDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory,
			directoryViewsFactory: self.sdk.makeDirectoryViewsFactory()
		)
	}

	private func makeFpsRestrictionsDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = FpsRestrictionsDemoViewModel(
			map: mapFactory.map,
			energyConsumption: mapFactory.energyConsumption
		)
		return FpsRestrictionsDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeGraphicsOptionsDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = GraphicsOptionsDemoViewModel(
			map: mapFactory.map,
			settingsService: self.settingsService
		)
		return GraphicsOptionsDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeLocaleDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = LocaleDemoViewModel(
			map: mapFactory.map,
			settingsService: self.settingsService,
			localeManager: self.localeManager
		)
		return LocaleDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeMapControlsDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = try MapControlsDemoViewModel(
			searchManager: self.makeSearchManager(),
			imageFactory: self.makeImageFactory(),
			map: mapFactory.map,
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService),
			logger: self.logger
		)
		return SwiftUIControlsDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeMapInteractionDemoPage() throws -> some View {
		MapInteractionDemoView {
			do {
				return try self.makeMapFactory()
			} catch let error as SimpleError {
				let errorMessage = "MapFactory initialization error: \(error.description)"
				self.logger.error(errorMessage)
				fatalError(errorMessage)
			} catch {
				let errorMessage = "MapFactory initialization error: \(error)"
				self.logger.error(errorMessage)
				fatalError(errorMessage)
			}
		}
	}

	private func makeMapObjectsDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = try MapObjectsDemoViewModel(
			map: mapFactory.map,
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService),
			imageFactory: self.sdk.imageFactory,
			modelFactory: self.makeModelFactory(),
			logger: self.logger
		)
		return MapObjectsDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeMapSnapshotDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = MapSnapshotDemoViewModel(sdk: self.sdk)
		return MapSnapshotDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeMapThemeDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = MapThemeDemoViewModel()
		return MapThemeDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeMapViewMarkersDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = try MapViewMarkersDemoViewModel(
			searchManager: self.makeSearchManager(),
			map: mapFactory.map,
			markerOverlayView: mapFactory.markerOverlayView,
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService),
			logger: self.logger
		)
		return MapViewMarkersDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeMultiViewPortsDemoPage() throws -> some View {
		let firstMapFactory = try self.makeMapFactory()
		let secondMapFactory = try self.makeMapFactory()
		let viewModel = MultiViewPortsDemoViewModel(
			firstMap: firstMapFactory.map,
			secondMap: secondMapFactory.map
		)
		return MultiViewPortsDemoView(
			viewModel: viewModel,
			firstMapFactory: firstMapFactory,
			secondMapFactory: secondMapFactory
		)
	}

	private func makeParkingsDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = try ParkingsDemoViewModel(
			map: mapFactory.map,
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService),
			searchManager: self.makeSearchManager(),
			logger: self.logger
		)
		return ParkingsDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeRasterTilesDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactoryWithStyles(stylesName: "custom-styles")
		let viewModel = try RasterTilesDemoViewModel(
			map: mapFactory.map,
			context: self.context
		)
		return RasterTilesDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeRoadEventsDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = RoadEventsDemoViewModel(
			map: mapFactory.map,
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService)
		)
		return try RoadEventsDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory,
			roadEventViewFactory: self.sdk.makeRoadEventViewFactory()
		)
	}

	private func makeStaticMapsDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = StaticMapsViewModel(
			map: mapFactory.map,
			logger: self.logger,
			imageFactory: self.makeImageFactory(),
			snapshotter: mapFactory.snapshotter
		)
		return StaticMapsView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeTrafficControlDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = TrafficControlDemoViewModel(
			map: mapFactory.map,
			logger: self.logger
		)
		return TrafficControlDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeVisibleAreaDetectionDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = VisibleAreaDetectionDemoViewModel(
			map: mapFactory.map,
			mapObjectManager: MapObjectManager(map: mapFactory.map),
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService)
		)
		return VisibleAreaDetectionDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeVisibleRectVisibleAreaDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = VisibleRectVisibleAreaDemoViewModel(
			map: mapFactory.map,
			logger: self.logger
		)
		return VisibleRectVisibleAreaDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}
}

extension SwiftUIDemoFactory {
	private func makeMiniMapDemoPage() throws -> some View {
		let source = self.makeMapSource()
		let mapFactory = try self.makeMapFactoryWithSource(source: source)
		let miniMapFactory = try self.makeMapFactoryWithStyles(stylesName: "minimap_styles", source: source)
		let targetMapFactory = try self.makeMapFactoryWithStyles(stylesName: "minimap_styles", source: source)
		let minimapViewModel = try MinimapDemoViewModel(
			map: mapFactory.map,
			miniMap: miniMapFactory.map,
			targetMiniMap: targetMapFactory.map,
			mainMapEnergyConsumption: mapFactory.energyConsumption,
			miniMapEnergyConsumption: miniMapFactory.energyConsumption,
			targetMiniMapEnergyConsumption: targetMapFactory.energyConsumption,
			imageFactory: self.makeImageFactory(),
			navigationManager: NavigationManager(platformContext: self.context),
			trafficRouter: TrafficRouter(context: self.context),
			logger: self.logger
		)
		return try MinimapDemoView(
			viewModel: minimapViewModel,
			mapFactory: mapFactory,
			miniMapFactory: miniMapFactory,
			targetMiniMapFactory: targetMapFactory
		)
	}

	private func makeNavigatorViewDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let mapSourceFactory = MapSourceFactory(
			context: self.context,
			settingsService: self.settingsService
		)
		let viewModel = try NavigatorDemoViewModel(
			map: mapFactory.map,
			mainMapEnergyConsumption: mapFactory.energyConsumption,
			trafficRouter: TrafficRouter(context: self.context),
			navigationManager: NavigationManager(platformContext: self.context),
			locationService: self.locationManagerFactory(),
			voiceManager: self.sdk.voiceManager,
			applicationIdleTimerService: self.applicationIdleTimerService,
			navigatorSettings: self.navigatorSettings,
			mapSourceFactory: mapSourceFactory,
			settingsService: self.settingsService,
			logger: self.logger,
			imageFactory: self.makeImageFactory()
		)
		var options = NavigationViewOptions.default
		if self.settingsService.navigatorTheme == .custom {
			options.theme = .custom
		}
		let navigationViewFactory = try self.sdk.makeNavigationViewFactory(options: options)
		return NavigatorDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory,
			navigationViewFactory: navigationViewFactory
		)
	}

	private func makeNavigatorWithMiniMapViewDemoPage() throws -> some View {
		let source = self.makeMapSource()
		let mapFactory = try self.makeMapFactoryWithSource(source: source)
		let miniMapFactory = try self.makeMapFactoryWithStyles(stylesName: "minimap_styles", source: source)
		let mapSourceFactory = MapSourceFactory(
			context: self.context,
			settingsService: self.settingsService
		)
		let viewModel = try NavigatorDemoViewModel(
			map: mapFactory.map,
			mainMapEnergyConsumption: mapFactory.energyConsumption,
			miniMapEnergyConsumption: miniMapFactory.energyConsumption,
			trafficRouter: TrafficRouter(context: self.context),
			navigationManager: NavigationManager(platformContext: self.context),
			locationService: self.locationManagerFactory(),
			voiceManager: self.sdk.voiceManager,
			applicationIdleTimerService: self.applicationIdleTimerService,
			navigatorSettings: self.navigatorSettings,
			mapSourceFactory: mapSourceFactory,
			settingsService: self.settingsService,
			logger: self.logger,
			imageFactory: self.makeImageFactory()
		)
		var options = NavigationViewOptions.default
		if self.settingsService.navigatorTheme == .custom {
			options.theme = .custom
		}
		let navigationViewFactory = try self.sdk.makeNavigationViewFactory(options: options)
		return NavigatorWithMiniMapView(
			viewModel: viewModel,
			mapFactory: mapFactory,
			miniMapFactory: miniMapFactory,
			navigationViewFactory: navigationViewFactory
		)
	}

	private func makeTerritoryManagerDemoView() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = try TerritoryManagerDemoViewModel(
			territoryManager: TerritoryManager.instance(context: self.context),
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService),
			map: mapFactory.map,
			locationService: self.sdk.locationService,
			logger: self.logger
		)
		return TerritoryManagerDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}

	private func makeRouteSearchDemoPage() throws -> some View {
		let mapFactory = try self.makeMapFactory()
		let viewModel = RouteSearchDemoViewModel(
			map: mapFactory.map,
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService),
			sourceFactory: { [sdk = self.sdk] in
				try! sdk.sourceFactory
			},
			routeEditorSourceFactory: { [context = self.context] routeEditor in
				return RouteEditorSource(context: context, routeEditor: routeEditor)
			},
			routeEditorFactory: { [context = self.context] in
				return RouteEditor(context: context)
			},
			feedbackGenerator: FeedbackGenerator(),
			navigationUIViewFactory: try! self.sdk.makeNavigationUIViewFactory()
		)
		return RouteSearchDemoView(
			viewModel: viewModel,
			mapFactory: mapFactory
		)
	}
}
