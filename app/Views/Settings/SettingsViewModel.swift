import Foundation
import Combine
import DGis

final class SettingsViewModel: ObservableObject {
	typealias MapDataSourceChangedCallback = (MapDataSource) -> Void

	let navigatorVoiceVolumeSources: [NavigatorVoiceVolumeSource]
	let navigatorThemes: [NavigatorTheme]
	let mapDataSources: [MapDataSource]
	let logLevels: [DGis.LogLevel]
	let mapThemes: [MapTheme]
	var mapDataSourceChangedCallback: MapDataSourceChangedCallback?
	@Published var mapDataSource: MapDataSource {
		didSet {
			if oldValue != self.mapDataSource {
				self.settingsService.mapDataSource = self.mapDataSource
				self.mapDataSourceChangedCallback?(self.mapDataSource)
			}
		}
	}
	@Published var language: Language {
		didSet {
			if oldValue != self.language {
				self.settingsService.language = self.language
			}
		}
	}
	@Published var httpCacheEnabled: Bool {
		didSet {
			if oldValue != self.httpCacheEnabled {
				self.settingsService.httpCacheEnabled = self.httpCacheEnabled
			}
		}
	}
	@Published var muteOtherSounds: Bool {
		didSet {
			if oldValue != self.muteOtherSounds {
				self.settingsService.muteOtherSounds = self.muteOtherSounds
			}
		}
	}
	@Published var addRoadEventSourceInNavigationView: Bool {
		didSet {
			if oldValue != self.addRoadEventSourceInNavigationView {
				self.settingsService.addRoadEventSourceInNavigationView = self.addRoadEventSourceInNavigationView
			}
		}
	}
	@Published var logLevelActionSheetShown: Bool = false
	@Published var logLevel: DGis.LogLevel {
		didSet {
			if oldValue != self.logLevel {
				self.settingsService.logLevel = logLevel
			}
		}
	}
	@Published var customStylePickerShown: Bool = false
	var customStyleUrl: URL? {
		didSet {
			if oldValue != self.customStyleUrl {
				self.customStyleChoosen = true
				self.settingsService.customStyleUrl = self.customStyleUrl
			}
		}
	}
	@Published var customStyleChoosen: Bool = false
	@Published var mapTheme: MapTheme {
		didSet {
			if oldValue != self.mapTheme {
				self.settingsService.mapTheme = self.mapTheme
			}
		}
	}
	@Published var navigatorVoiceVolumeSource: NavigatorVoiceVolumeSource {
		didSet {
			if oldValue != self.navigatorVoiceVolumeSource {
				self.settingsService.navigatorVoiceVolumeSource = self.navigatorVoiceVolumeSource
			}
		}
	}
	@Published var navigatorTheme: NavigatorTheme {
		didSet {
			if oldValue != self.navigatorTheme {
				self.settingsService.navigatorTheme = self.navigatorTheme
			}
		}
	}
	private let settingsService: ISettingsService

	init(
		settingsService: ISettingsService,
		mapDataSources: [MapDataSource] = MapDataSource.allCases,
		navigatorVoiceVolumeSources: [NavigatorVoiceVolumeSource] = NavigatorVoiceVolumeSource.allCases,
		navigatorThemes: [NavigatorTheme] = NavigatorTheme.allCases,
		logLevels: [DGis.LogLevel] = DGis.LogLevel.availableLevels,
		mapThemes: [MapTheme] = MapTheme.allCases
	) {
		self.settingsService = settingsService
		self.mapDataSources = mapDataSources
		self.mapDataSource = settingsService.mapDataSource
		self.language = settingsService.language
		self.navigatorVoiceVolumeSources = navigatorVoiceVolumeSources
		self.navigatorThemes = navigatorThemes
		self.navigatorTheme = settingsService.navigatorTheme
		self.navigatorVoiceVolumeSource = settingsService.navigatorVoiceVolumeSource
		self.httpCacheEnabled = settingsService.httpCacheEnabled
		self.muteOtherSounds = settingsService.muteOtherSounds
		self.addRoadEventSourceInNavigationView = settingsService.addRoadEventSourceInNavigationView
		self.logLevel = settingsService.logLevel
		self.logLevels = logLevels
		self.mapTheme = settingsService.mapTheme
		self.mapThemes = mapThemes
		self.customStyleUrl = settingsService.customStyleUrl
		if self.customStyleUrl != nil { self.customStyleChoosen = true }
	}

	func selectLogLevel() {
		self.logLevelActionSheetShown = true
	}
}
