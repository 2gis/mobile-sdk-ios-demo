import SwiftUI
import DGis

final class Container {
	static let shared = Container()
	private lazy var languageSettings: ILanguageSettings = LanguageSettings()
	lazy var logger: ILogger = Logger()
	private lazy var customLogSink = ConsoleLogSink(logger: self.logger)
	
	private var keySource: KeySource = .default

	private(set) lazy var sdk: DGis.Container = {
		let logOptions = LogOptions(
			systemLevel: self.settingsService.logLevel,
			customLevel: self.settingsService.logLevel,
			customSink: self.customLogSink
		)
		let httpOptions = HttpOptions(
			timeout: self.settingsService.httpTimeout,
			useCache: self.settingsService.httpCacheEnabled
		)
		let vendorConfigFile = Bundle.main.path(forResource: "vendor-config", ofType: "jsonx").map {
			VendorConfig.fromFile(VendorConfigFromFile(path: $0))
		}
		return DGis.Container(
			keySource: self.keySource,
			logOptions: logOptions,
			httpOptions: httpOptions,
			vendorConfig: vendorConfigFile ?? .none
		)
	}()
	private var applicationIdleTimerService: IApplicationIdleTimerService {
		UIApplication.shared
	}
	private lazy var settingsStorage: IKeyValueStorage = UserDefaults.standard
	private lazy var navigatorSettings: INavigatorSettings = NavigatorSettings(storage: self.settingsStorage)
	lazy var settingsService: ISettingsService = {
		let service = SettingsService(
			languageSettings: self.languageSettings,
			storage: self.settingsStorage
		)
		service.onCurrentLanguageDidChange = { [weak self] in
			self?.mapFactoryProvider.resetMapFactory()
		}
		return service
	}()
	
	private lazy var navigationService: NavigationService = NavigationService()
	
	private lazy var mapFactoryProvider = MapFactoryProvider(container: self.sdk, mapGesturesType: .default(.event))
	
	init() {}
	
	func makeRootView() throws -> some View {
		let viewModel = self.makeRootViewModel()
		let swiftUIFactory = try self.makeSwiftUIFactory()
		let uiKitFactory = try self.makeUIKitFactory()
		return RootView(
			viewModel: viewModel,
			swiftUIFactory: swiftUIFactory,
			uiKitFactory: uiKitFactory
		)
		.environmentObject(self.navigationService)
	}
	
	private func makeRootViewModel() -> RootViewModel {
		RootViewModel(
			demos: DemoPage.allCases,
			settingsService: self.settingsService,
			settingsViewModel: SettingsViewModel(
				settingsService: self.settingsService,
				logger: self.logger,
				customStyleUrl: self.settingsService.customStyleUrl
			)
		)
	}
	
	private func makeSwiftUIFactory() throws -> SwiftUIDemoFactory {
		let viewFactory = try SwiftUIDemoFactory(
			sdk: self.sdk,
			snapshotterProvider: self.mapFactoryProvider,
			settingsService: self.settingsService,
			mapProvider: self.mapFactoryProvider,
			applicationIdleTimerService: self.applicationIdleTimerService,
			navigatorSettings: self.navigatorSettings,
			logger: self.logger
		)
		return viewFactory
	}
	
	private func makeUIKitFactory() throws -> UIKitDemoFactory {
		let viewFactory = try UIKitDemoFactory(
			sdk: self.sdk,
			snapshotterProvider: self.mapFactoryProvider,
			settingsService: self.settingsService,
			mapProvider: self.mapFactoryProvider,
			applicationIdleTimerService: self.applicationIdleTimerService,
			navigatorSettings: self.navigatorSettings,
			logger: self.logger
		)
		return viewFactory
	}
}
