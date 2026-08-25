import Combine
import DGis
import Foundation
import UIKit.UIScreen

@MainActor
class RootViewFactory: ObservableObject {
	let sdk: DGis.Container
	let context: Context
	let locationManagerFactory: () -> ILocationService
	let snapshotterProvider: IMapSnapshotterProvider
	let settingsService: ISettingsService
	let mapProvider: IMapProvider
	let applicationIdleTimerService: IApplicationIdleTimerService
	let navigatorSettings: INavigatorSettings
	let logger: ILogger
	let localeManager: LocaleManager

	init(
		sdk: DGis.Container,
		locationManagerFactory: @escaping () -> ILocationService,
		snapshotterProvider: IMapSnapshotterProvider,
		settingsService: ISettingsService,
		mapProvider: IMapProvider,
		applicationIdleTimerService: IApplicationIdleTimerService,
		navigatorSettings: INavigatorSettings,
		logger: ILogger
	) throws {
		self.sdk = sdk
		self.context = try self.sdk.context
		self.locationManagerFactory = locationManagerFactory
		self.snapshotterProvider = snapshotterProvider
		self.settingsService = settingsService
		self.mapProvider = mapProvider
		self.applicationIdleTimerService = applicationIdleTimerService
		self.navigatorSettings = navigatorSettings
		self.logger = logger

		self.localeManager = try self.sdk.localeManager
		let locales = settingsService.language.locale.map { [$0] }
		self.localeManager.overrideLocales(locales: locales ?? [])
	}

	func makeMapControllerOptions(
		sources: [Source]? = nil,
		styleURL: URL? = nil
	) -> MapControllerOptions {
		var options = MapControllerOptions(
			sources: sources ?? self.makeDefaultMapSources(),
			graphicsPreset: self.settingsService.graphicsOption.preset,
			mapAppearance: self.settingsService.mapTheme.mapAppearance
		)
		if let styleURL {
			options.styleFile = File(path: styleURL.standardized.path)
		} else if let styleURL = self.settingsService.customStyleUrl {
			options.styleFile = File(path: styleURL.standardized.path)
		}
		return options
	}

	func makeMapViewOptions() -> MapViewOptions {
		MapViewOptions.default
	}

	func makeMapFactory(
		sources: [Source]? = nil,
		styleURL: URL? = nil
	) throws -> IMapFactory {
		try self.sdk.makeMapFactory(
			options: self.makeMapControllerOptions(sources: sources, styleURL: styleURL),
			mapViewOptions: self.makeMapViewOptions()
		)
	}

	func makeMapFactoryWithSource(source: Source) throws -> IMapFactory {
		try self.makeMapFactory(
			sources: [source, self.makeSourceFactory().createImmersiveDgisSource()]
		)
	}

	func makeMapFactoryWithStyles(stylesName: String) throws -> IMapFactory {
		try self.makeMapFactory(
			styleURL: Bundle.main.url(forResource: stylesName, withExtension: "2gis")
		)
	}

	func makeMapFactoryWithStyles(stylesName: String, source: Source) throws -> IMapFactory {
		try self.makeMapFactory(
			sources: [source],
			styleURL: Bundle.main.url(forResource: stylesName, withExtension: "2gis")
		)
	}

	func makeMapSource() -> Source {
		let sourceFactory: ISourceFactory
		do {
			sourceFactory = try self.sdk.sourceFactory
		} catch let error as SimpleError {
			let errorMessage = "ISourceFactory initialization error: \(error.description)"
			self.logger.error(errorMessage)
			fatalError(errorMessage)
		} catch {
			let errorMessage = "ISourceFactory initialization error: \(error)"
			self.logger.error(errorMessage)
			fatalError(errorMessage)
		}
		switch self.settingsService.mapDataSource {
		case .online:
			return sourceFactory.createOnlineDGISSource()
		case .hybrid:
			return sourceFactory.createHybridDGISSource()
		case .offline:
			return sourceFactory.createOfflineDGISSource()
		@unknown default:
			assertionFailure("Unknown type: \(self)")
		}
	}

	func makeImageFactory() -> IImageFactory {
		do {
			return try self.sdk.imageFactory
		} catch let error as SimpleError {
			let errorMessage = "IImageFactory initialization error: \(error.description)"
			self.logger.error(errorMessage)
			fatalError(errorMessage)
		} catch {
			let errorMessage = "IImageFactory initialization error: \(error)"
			self.logger.error(errorMessage)
			fatalError(errorMessage)
		}
	}

	func makeModelFactory() -> IModelFactory {
		do {
			return try self.sdk.modelFactory
		} catch let error as SimpleError {
			let errorMessage = "IModelFactory initialization error: \(error.description)"
			self.logger.error(errorMessage)
			fatalError(errorMessage)
		} catch {
			let errorMessage = "IModelFactory initialization error: \(error)"
			self.logger.error(errorMessage)
			fatalError(errorMessage)
		}
	}

	func makeSearchManager() throws -> SearchManager {
		switch self.settingsService.mapDataSource {
		case .online:
			return try SearchManager.createOnlineManager(context: self.context)
		case .hybrid:
			return try SearchManager.createSmartManager(context: self.context)
		case .offline:
			return try SearchManager.createOfflineManager(context: self.context)
		@unknown default:
			assertionFailure("Unknown type: \(self)")
		}
	}

    func makeTrafficRouter() -> TrafficRouter {
        let routerType: RouterType = switch self.settingsService.mapDataSource {
        case .online: .online
        case .hybrid: .hybrid
        case .offline: .offline
        }
        return TrafficRouter(context: self.context, routerType: routerType)
    }

	func makeSearchHistory() -> SearchHistory {
		SearchHistory.instance(context: self.context)
	}

	func makeHttpCacheManager() throws -> HttpCacheManager {
		guard let cacheManager = HttpCacheManager.get(context: self.context) else {
			throw SimpleError(description: "Failed to get cache manager. Enable cache in settings and restart testapp")
		}
		return cacheManager
	}

	func makeRoadEventUIViewFactory() -> IRoadEventUIViewFactory {
		do {
			return try self.sdk.makeRoadEventUIViewFactory()
		} catch let error as SimpleError {
			let errorMessage = "IRoadEventUIViewFactory initialization error: \(error.description)"
			self.logger.error(errorMessage)
			fatalError(errorMessage)
		} catch {
			let errorMessage = "IRoadEventUIViewFactory initialization error: \(error)"
			self.logger.error(errorMessage)
			fatalError(errorMessage)
		}
	}

	func makeMapMarkerPresenter() -> MapMarkerPresenter {
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

	func makeGeometrySource() throws -> GeometryMapObjectSource {
		try self.sdk.sourceFactory.createGeometryMapObjectSourceBuilder().createSource()
	}

	private func makeSourceFactory() -> ISourceFactory {
		do {
			return try self.sdk.sourceFactory
		} catch let error as SimpleError {
			let errorMessage = "ISourceFactory initialization error: \(error.description)"
			self.logger.error(errorMessage)
			fatalError(errorMessage)
		} catch {
			let errorMessage = "ISourceFactory initialization error: \(error)"
			self.logger.error(errorMessage)
			fatalError(errorMessage)
		}
	}

	private func makeDefaultMapSources() -> [Source] {
		[
			self.makeMapSource(),
			self.makeSourceFactory().createImmersiveDgisSource(),
		]
	}
}
