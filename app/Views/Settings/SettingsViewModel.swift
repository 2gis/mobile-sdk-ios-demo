import Foundation
import Combine
import DGis

final class SettingsViewModel: ObservableObject {
	typealias MapDataSourceChangedCallback = (MapDataSource) -> Void

	let navigatorThemes: [NavigatorTheme]
	let navigatorControlsList: [NavigatorControls]
	let navigatorDashboardButtons: [NavigatorDashboardButton]
	let mapDataSources: [MapDataSource]
	let logLevels: [DGis.LogLevel]
	let mapThemes: [MapTheme]
	let geolocationMarkerTypes: [GeolocationMarkerType]
	let graphicsOptions: [GraphicsOption]
	let fileManager: FileManager
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
	@Published var httpTimeout: Double {
		didSet {
			if oldValue != self.httpTimeout {
				self.settingsService.httpTimeout = self.httpTimeout
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
				self.settingsService.logLevel = self.logLevel
			}
		}
	}
	@Published var customStylePickerShown: Bool = false
	var customStyleUrl: URL? {
		didSet {
			if oldValue != self.customStyleUrl {
				self.settingsService.customStyleUrl = self.customStyleUrl
			}
		}
	}
	@Published private(set) var selectedStyle: URL?
	@Published var styles: [URL] = []
	@Published var newStyleURL: URL? {
		didSet {
			if let url = self.newStyleURL,
			   !self.styles.contains(url) {
				self.addNewStyle(from: url)
			}
		}
	}
	@Published var mapTheme: MapTheme {
		didSet {
			if oldValue != self.mapTheme {
				self.settingsService.mapTheme = self.mapTheme
			}
		}
	}
	
	@Published var geolocationMarkerType: GeolocationMarkerType {
		didSet {
			if oldValue != self.geolocationMarkerType {
				self.settingsService.geolocationMarkerType = self.geolocationMarkerType
			}
		}
	}

	@Published var graphicsOption: GraphicsOption {
		didSet {
			if oldValue != self.graphicsOption {
				self.settingsService.graphicsOption = self.graphicsOption
			}
		}
	}
	@Published var navigatorVoiceVolume: Double {
		didSet {
			if oldValue != self.navigatorVoiceVolume {
				self.settingsService.navigatorVoiceVolume = UInt32(self.navigatorVoiceVolume)
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
	@Published var navigatorControls: NavigatorControls {
		didSet {
			if oldValue != self.navigatorControls {
				self.settingsService.navigatorControls = self.navigatorControls
			}
		}
	}
	@Published var navigatorDashboardButton: NavigatorDashboardButton {
		didSet {
			if oldValue != self.navigatorDashboardButton {
				self.settingsService.navigatorDashboardButton = self.navigatorDashboardButton
			}
		}
	}
	let logger: ILogger
	private let settingsService: ISettingsService

	init(
		settingsService: ISettingsService,
		mapDataSources: [MapDataSource] = MapDataSource.allCases,
		navigatorThemes: [NavigatorTheme] = NavigatorTheme.allCases,
		navigatorControlsList: [NavigatorControls] = NavigatorControls.allCases,
		navigatorDashboardButtons: [NavigatorDashboardButton] = NavigatorDashboardButton.allCases,
		logLevels: [DGis.LogLevel] = DGis.LogLevel.availableLevels,
		mapThemes: [MapTheme] = MapTheme.allCases,
		geolocationMarkerTypes: [GeolocationMarkerType] = GeolocationMarkerType.allCases,
		logger: ILogger,
		customStyleUrl: URL?,
		graphicsOptions:[GraphicsOption] = GraphicsOption.allCases
	) {
		self.settingsService = settingsService
		self.mapDataSources = mapDataSources
		self.mapDataSource = settingsService.mapDataSource
		self.navigatorThemes = navigatorThemes
		self.navigatorTheme = settingsService.navigatorTheme
		self.navigatorControlsList = navigatorControlsList
		self.navigatorControls = settingsService.navigatorControls
        self.navigatorDashboardButtons = navigatorDashboardButtons
        self.navigatorDashboardButton = settingsService.navigatorDashboardButton
		self.navigatorVoiceVolume = Double(settingsService.navigatorVoiceVolume)
		self.httpCacheEnabled = settingsService.httpCacheEnabled
		self.httpTimeout = settingsService.httpTimeout
		self.muteOtherSounds = settingsService.muteOtherSounds
		self.addRoadEventSourceInNavigationView = settingsService.addRoadEventSourceInNavigationView
		self.logLevel = settingsService.logLevel
		self.logLevels = logLevels
		self.mapTheme = settingsService.mapTheme
		self.mapThemes = mapThemes
		self.geolocationMarkerType = settingsService.geolocationMarkerType
		self.geolocationMarkerTypes = geolocationMarkerTypes
		self.logger = logger
		self.language = settingsService.language
		self.customStyleUrl = settingsService.customStyleUrl
		self.graphicsOption = settingsService.graphicsOption
		self.graphicsOptions = graphicsOptions
		self.fileManager = FileManager.default
		self.loadStyles()
	}

	func selectLogLevel() {
		self.logLevelActionSheetShown = true
	}

	func getDefaultStyleURL() -> URL {
		return URL(string: "Default")!
	}

	func saveStyleURL(_ url: URL?) {
		if url == self.getDefaultStyleURL() {
			self.settingsService.customStyleUrl = nil
			self.selectedStyle = self.getDefaultStyleURL()
		} else {
			self.settingsService.customStyleUrl = url
			self.selectedStyle = url
		}
	}

	func deleteStyle(_ style: URL) {
		guard style != self.getDefaultStyleURL() else { return }
		if style == self.selectedStyle {
			self.saveStyleURL(self.getDefaultStyleURL())
		}
		do {
			try self.fileManager.removeItem(at: style)
			self.loadStyles()
		} catch {
			self.logger.error("Error deleting style: \(error)")
		}
	}

	private func loadStyles() {
		self.styles = [self.getDefaultStyleURL()]
		guard let stylesDirectory = self.getStylesDirectory() else { return }
		do {
			let styleFiles = try self.fileManager.contentsOfDirectory(at: stylesDirectory, includingPropertiesForKeys: nil, options: [])
			self.styles += styleFiles
		} catch {
			self.logger.error("Error loading styles: \(error)")
		}
		if let styleUrl = self.settingsService.customStyleUrl {
			self.selectedStyle = styleUrl
		} else {
			self.selectedStyle = self.getDefaultStyleURL()
		}
	}

	private func getStylesDirectory() -> URL? {
		let paths = self.fileManager.urls(for: .documentDirectory, in: .userDomainMask)
		guard let documentDirectory = paths.first else { return nil }
		let stylesDirectory = documentDirectory.appendingPathComponent("Styles")
		if !self.fileManager.fileExists(atPath: stylesDirectory.path) {
			do {
				try self.fileManager.createDirectory(at: stylesDirectory, withIntermediateDirectories: true, attributes: nil)
			} catch {
				self.logger.error("Error creating Styles directory: \(error)")
				return nil
			}
		}
		return stylesDirectory
	}

	private func addNewStyle(from url: URL) {
		guard let stylesDirectory = getStylesDirectory() else { return }
		let destinationURL = stylesDirectory.appendingPathComponent(url.lastPathComponent)
		do {
			try self.fileManager.copyItem(at: url, to: destinationURL)
			self.loadStyles()
		} catch {
			self.logger.error("Error copying style: \(error)")
		}
	}
}
