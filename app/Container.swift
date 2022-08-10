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
		let audioOptions = AudioOptions(
			muteOtherSounds: self.settingsService.muteOtherSounds,
			audioVolume: AudioVolume(self.settingsService.navigatorVoiceVolumeSource)
		)
		return DGis.Container(
			apiKeyOptions: .default,
			logOptions: logOptions,
			httpOptions: httpOptions,
			audioOptions: audioOptions
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
		service.onCurrentLanguageDidChange = { [weak self] in
			self?.mapFactoryProvider.resetMapFactory()
		}
		service.onMuteOtherSoundsDidChange = { [weak self] value in
			self?.sdk.audioSettings.muteOtherSounds = value
		}
		service.onNavigatorVoiceVolumeSourceDidChange = { [weak self] value in
			self?.sdk.audioSettings.audioVolume = value
		}
		return service
	}()

	private lazy var locationGeneratorPositioningQueue: DispatchQueue = DispatchQueue(
		label: "ru.2gis.sdk.app.positioning-queue",
		qos: .default
	)

	private lazy var mapFactoryProvider = MapFactoryProvider(container: self.sdk, mapGesturesType: .default(.event))

	private lazy var navigationService: NavigationService = NavigationService()

	func makeRootView() -> some View {
		let viewModel = self.makeRootViewModel()
		let viewFactory = self.makeRootViewFactory()
		return RootView(
			viewModel: viewModel,
			viewFactory: viewFactory
		)
		.environmentObject(self.navigationService)
	}

	private func makeRootViewFactory() -> RootViewFactory {
		let viewFactory = RootViewFactory(
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
