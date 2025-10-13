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
	lazy var styleFactory: IStyleFactory = self.makeStyleFactory()

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

	func makeMapOptions() -> MapOptions {
		var options = MapOptions.default
		options.maxFps = UIScreen.main.maximumFramesPerSecond
		options.graphicsPreset = self.settingsService.graphicsOption.preset
		if let styleUrl = self.settingsService.customStyleUrl {
			options.styleFuture = self.styleFactory.loadFile(url: styleUrl)
		}
		options.appearance = self.settingsService.mapTheme.mapAppearance
		return options
	}

	func makeMapFactory() throws -> IMapFactory {
		var options = self.makeMapOptions()
		options.sourceDescriptors = [self.settingsService.mapDataSource.sourceDescriptor]
		return try self.sdk.makeMapFactory(options: options)
	}

	func makeMapFactoryWithSource(source: Source) throws -> IMapFactory {
		var options = self.makeMapOptions()
		options.sources = [source, self.makeSourceFactory().createImmersiveDgisSource()]
		return try self.sdk.makeMapFactory(options: options)
	}

	func makeMapFactoryWithStyles(stylesName: String) throws -> IMapFactory {
		var options = self.makeMapOptions()
		if let stylesURL = Bundle.main.url(forResource: stylesName, withExtension: "2gis") {
			options.styleFuture = self.styleFactory.loadFile(url: stylesURL)
		}
		return try self.sdk.makeMapFactory(options: options)
	}

	func makeMapFactoryWithStyles(stylesName: String, source: Source) throws -> IMapFactory {
		var options = self.makeMapOptions()
		options.sources = [source]
		if let stylesURL = Bundle.main.url(forResource: stylesName, withExtension: "2gis") {
			options.styleFuture = self.styleFactory.loadFile(url: stylesURL)
		}
		return try self.sdk.makeMapFactory(options: options)
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

	func makeStyleFactory() -> IStyleFactory {
		do {
			return try self.sdk.styleFactory
		} catch let error as SimpleError {
			let errorMessage = "IStyleFactory initialization error: \(error.description)"
			self.logger.error(errorMessage)
			fatalError(errorMessage)
		} catch {
			let errorMessage = "IStyleFactory initialization error: \(error)"
			self.logger.error(errorMessage)
			fatalError(errorMessage)
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
}

extension MapDataSource {
	var sourceDescriptor: MapOptions.SourceDescriptor {
		switch self {
		case .online:
			return .dgisOnlineSource
		case .hybrid:
			return .dgisHybridSource
		case .offline:
			return .dgisOfflineSource
		@unknown default:
			assertionFailure("Unknown type: \(self)")
		}
	}
}
