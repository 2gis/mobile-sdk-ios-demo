import SwiftUI
import DGis

final class Container {
	private(set) lazy var sdk: DGis.Container = {
		var cacheOptions: HTTPOptions.CacheOptions?
		if self.settingsService.httpCacheEnabled {
			cacheOptions = HTTPOptions.default.cacheOptions
		} else {
			cacheOptions = nil
		}

		let logOptions = LogOptions(
			osLogLevel: self.settingsService.logLevel,
			customLogLevel: self.settingsService.logLevel,
			customSink: nil
		)
		let httpOptions = HTTPOptions(timeout: 15, cacheOptions: cacheOptions)
		return DGis.Container(
			apiKeyOptions: .default,
			logOptions: logOptions,
			httpOptions: httpOptions
		)
	}()

	private var applicationIdleTimerService: IApplicationIdleTimerService {
		UIApplication.shared
	}
	private lazy var settingsStorage: IKeyValueStorage = UserDefaults.standard
	private lazy var navigatorSettings: INavigatorSettings = NavigatorSettings(storage: self.settingsStorage)

	private lazy var settingsService: ISettingsService = {
		let service = SettingsService(
			storage: self.settingsStorage
		)
		return service
	}()

	private lazy var locationGeneratorPositioningQueue: DispatchQueue = DispatchQueue(
		label: "ru.2gis.sdk.app.positioning-queue",
		qos: .default
	)

	private lazy var mapFactoryProvider = MapFactoryProvider(container: self.sdk, mapGesturesType: .default(.event))

	private lazy var navigationService: NavigationService = NavigationService()

	private var localeManager: LocaleManager?

	func makeRootView() throws -> some View {
		let viewModel = self.makeRootViewModel()
		let viewFactory = try self.makeRootViewFactory()
		return RootView(
			viewModel: viewModel,
			viewFactory: viewFactory
		)
		.environmentObject(self.navigationService)
	}

	private func makeRootViewFactory() throws -> RootViewFactory {
		self.localeManager = try self.sdk.makeLocaleManager()
		let locales = settingsService.language.locale.map { [$0] }
		self.localeManager?.overrideLocales(locales: locales ?? [])
		self.settingsService.onCurrentLanguageDidChange = { [weak self] language in
			self?.mapFactoryProvider.resetMapFactory()
			let locales = language.locale.map { [$0] }
			self?.localeManager?.overrideLocales(locales: locales ?? [])
		}

		let viewFactory = try RootViewFactory(
			sdk: self.sdk,
			locationManagerFactory: {
				LocationService()
			},
			settingsService: self.settingsService,
			mapProvider: self.mapFactoryProvider,
			applicationIdleTimerService: self.applicationIdleTimerService,
			navigatorSettings: self.navigatorSettings
		)
		return viewFactory
	}

	private func makeRootViewModel() -> RootViewModel {
		let rootViewModel = RootViewModel(
			demoPages: DemoPage.allCases,
			settingsService: self.settingsService,
			settingsViewModel: SettingsViewModel(
				settingsService: settingsService
			)
		)
		return rootViewModel
	}
}
