import Foundation
import Combine
import DGis

final class SettingsViewModel: ObservableObject {
	typealias MapDataSourceChangedCallback = (MapDataSource) -> Void

	let navigatorThemes: [NavigatorTheme]
	let mapDataSources: [MapDataSource]
	let logLevels: [DGis.LogLevel]
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
	private let settingsService: ISettingsService

	init(
		settingsService: ISettingsService,
		mapDataSources: [MapDataSource] = MapDataSource.allCases,
		navigatorThemes: [NavigatorTheme] = NavigatorTheme.allCases,
		logLevels: [DGis.LogLevel] = DGis.LogLevel.availableLevels
	) {
		self.settingsService = settingsService
		self.mapDataSources = mapDataSources
		self.mapDataSource = settingsService.mapDataSource
		self.language = settingsService.language
		self.navigatorThemes = navigatorThemes
		self.httpCacheEnabled = settingsService.httpCacheEnabled
		self.muteOtherSounds = settingsService.muteOtherSounds
		self.addRoadEventSourceInNavigationView = settingsService.addRoadEventSourceInNavigationView
		self.logLevel = settingsService.logLevel
		self.logLevels = logLevels
	}

	func selectLogLevel() {
		self.logLevelActionSheetShown = true
	}
}
