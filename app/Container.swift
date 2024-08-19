import SwiftUI
import DGis

final class Container {
	private(set) lazy var sdk: DGis.Container = {
		let logOptions = LogOptions(
			systemLevel: self.settingsService.logLevel,
			customLevel: self.settingsService.logLevel,
			customSink: nil
		)
		let httpOptions = HttpOptions(
			timeout: 15,
			useCache: self.settingsService.httpCacheEnabled
		)
		let container = DGis.Container(
			keySource: .default,
			logOptions: logOptions,
			httpOptions: httpOptions
		)
		if let audioSettings = try? container.audioSettings {
			audioSettings.audioFocusPolicy = self.settingsService.muteOtherSounds ? .duck : .ignore
			audioSettings.volume = self.settingsService.navigatorVoiceVolume
		}
		return container
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
		service.onMuteOtherSoundsDidChange = { [weak self] value in
			guard
				let audioSettings = try? self?.sdk.audioSettings
			else {
				return
			}
			audioSettings.audioFocusPolicy = value ? .duck : .ignore
		}
		service.onNavigatorVoiceVolumeSourceDidChange = { [weak self] value in
			guard
				let audioSettings = try? self?.sdk.audioSettings
			else {
				return
			}
			audioSettings.volume = value
		}
		service.onCurrentLanguageDidChange = { [weak self] (Language) -> Void in
			self?.mapFactoryProvider.resetMapFactory()
		}
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
