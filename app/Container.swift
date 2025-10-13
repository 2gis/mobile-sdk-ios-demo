import DGis
import SwiftUI

final class Container {
	@MainActor static let shared = Container()
	private lazy var languageSettings: ILanguageSettings = LanguageSettings()
	lazy var logger: ILogger = Logger()
	private lazy var customLogSink = ConsoleLogSink(logger: self.logger)
	private lazy var locationGeneratorPositioningQueue: DispatchQueue = .init(
		label: "ru.mobile.sdk.app-swiftui.positioning-queue",
		qos: .default
	)

	private lazy var locationGeneratorReceiver: ILocationGeneratorReceiver = LocationGeneratorReceiver(
		port: 8899,
		queue: self.locationGeneratorPositioningQueue,
		logger: self.logger
	)

	private lazy var generatorLocationProvider = GeneratorLocationProvider(
		queue: self.locationGeneratorPositioningQueue,
		receiver: self.locationGeneratorReceiver
	)

	private var keySource: KeySource = .default

	@MainActor
	private(set) lazy var sdk: DGis.Container = {
		let locationProvider: ILocationProvider? = switch self.settingsService.positioningServicesSource {
		case .default:
			nil
		case .generator:
			self.generatorLocationProvider
		@unknown default:
			nil
		}

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
			locationProvider: locationProvider,
			vendorConfig: vendorConfigFile ?? .none
		)
	}()

	@MainActor
	private var applicationIdleTimerService: IApplicationIdleTimerService {
		UIApplication.shared
	}

	private lazy var settingsStorage: IKeyValueStorage = UserDefaults.standard
	private lazy var navigatorSettings: INavigatorSettings = NavigatorSettings(storage: self.settingsStorage)
	@MainActor
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

	@MainActor
	private lazy var navigationService: NavigationService = .init()

	@MainActor
	private lazy var mapFactoryProvider = MapFactoryProvider(container: self.sdk, mapGesturesType: .default(.event))

	init() {}

	@MainActor
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

	@MainActor
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

	@MainActor
	private func makeSwiftUIFactory() throws -> SwiftUIDemoFactory {
		let viewFactory = try SwiftUIDemoFactory(
			sdk: self.sdk,
			locationManagerFactory: { [unowned self] in
				switch self.settingsService.positioningServicesSource {
				case .default:
					return LocationService()
				case .generator:
					return GeneratorLocationService(locationProvider: self.generatorLocationProvider)
				@unknown default:
					assertionFailure("Unknown value for PositioningServicesSource")
				}
			},
			snapshotterProvider: self.mapFactoryProvider,
			settingsService: self.settingsService,
			mapProvider: self.mapFactoryProvider,
			applicationIdleTimerService: self.applicationIdleTimerService,
			navigatorSettings: self.navigatorSettings,
			logger: self.logger
		)
		return viewFactory
	}

	@MainActor
	private func makeUIKitFactory() throws -> UIKitDemoFactory {
		let viewFactory = try UIKitDemoFactory(
			sdk: self.sdk,
			locationManagerFactory: { [unowned self] in
				switch self.settingsService.positioningServicesSource {
				case .default:
					return LocationService()
				case .generator:
					return GeneratorLocationService(locationProvider: self.generatorLocationProvider)
				@unknown default:
					assertionFailure("Unknown value for PositioningServicesSource")
				}
			},
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
