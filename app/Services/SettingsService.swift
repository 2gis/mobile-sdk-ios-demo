import Foundation
import DGis

protocol ISettingsService: AnyObject {
	var supportedLanguages: [Language] { get }
	var currentLanguage: Language { get }
	var onCurrentLanguageDidChange: (() -> Void)? { get set }
	var customStyleUrl: URL? { get set }
	var mapDataSource: MapDataSource { get set }
	var language: Language { get set }
	var positioningServicesSource: PositioningServicesSource { get set }
	var httpCacheEnabled: Bool { get set }
	var httpTimeout: Double { get set }
	var muteOtherSounds: Bool { get set }
	var addRoadEventSourceInNavigationView: Bool { get set }
	var logLevel: DGis.LogLevel { get set }
	var mapTheme: MapTheme { get set }
	var geolocationMarkerType: GeolocationMarkerType { get set }
	var graphicsOption: GraphicsOption { get set }
	var navigatorVoiceVolume: UInt32 { get set }
	var navigatorTheme: NavigatorTheme { get set }
	var navigatorControls: NavigatorControls { get set }
	var navigatorDashboardButton: NavigatorDashboardButton { get set }
	var isMiniMapSelected: Bool { get set }

	func setLanguage(_ language: Language)
}

final class SettingsService: ISettingsService {
	private enum Keys {
		static let mapDataSource = "Global/MapDataSource"
		static let language = "Global/Language"
		static let customStyleURL = "Global/CustomStyleURL"
		static let positioningServicesSource = "Global/PositioningServicesSource"
		static let httpCacheEnabled = "Global/HttpCacheEnabled"
		static let httpTimeout = "Global/HttpTimeout"
		static let muteOtherSounds = "Global/MuteOtherSounds"
		static let navigatorVoiceVolume = "Global/NavigatorVoiceVolumeSource"
		static let navigatorTheme = "Global/NavigatorTheme"
		static let navigatorControls = "Global/NavigatorControls"
		static let navigatorDashboardButton = "Global/NavigatorDashboardButton"
		static let addRoadEventSourceInNavigationView = "Global/AddRoadEventSourceInNavigationView"
		static let logLevel = "Global/LogLevel"
		static let mapTheme = "Global/MapTheme"
		static let geolocationMarkerType = "Global/GeolocationMarkerType"
		static let graphicsOption = "Global/GraphicsOption"
		static let isMiniMapSelected = "Global/IsMiniMapSelected"
	}

	private enum Constants {
		static let httpTimeoutDefault: Double = 15.0
	}

	var currentLanguage: Language {
		return self.languageSettings.currentLanguage
	}
	var supportedLanguages: [Language] {
		return self.languageSettings.supportedLanguages
	}
	
	var customStyleUrl: URL? {
		get {
			if let rawValue: String = self.storage.value(forKey: Keys.customStyleURL),
			   let url = URL(string: rawValue),
			   FileManager.default.fileExists(atPath: url.path) 
			{
				return url
			} else {
				return nil
			}
		}
		set {
			self.storage.set(newValue?.absoluteString ?? nil, forKey: Keys.customStyleURL)
		}
	}

	var positioningServicesSource: PositioningServicesSource {
		get {
			let rawValue: String? = self.storage.value(forKey: Keys.positioningServicesSource)
			return rawValue.flatMap { PositioningServicesSource(rawValue: $0) } ?? .default
		}
		set {
			self.storage.set(newValue.rawValue, forKey: Keys.positioningServicesSource)
		}
	}
	var onCurrentLanguageDidChange: (() -> Void)?

	var mapDataSource: MapDataSource {
		get {
			let rawValue: String? = self.storage.value(forKey: Keys.mapDataSource)
			return rawValue.flatMap { MapDataSource(rawValue: $0) } ?? .default
		}
		set {
			self.storage.set(newValue.rawValue, forKey: Keys.mapDataSource)
		}
	}

	var language: Language {
		get {
			let rawValue: String? = self.storage.value(forKey: Keys.language)
			return rawValue.flatMap { Language(rawValue: $0) } ?? .default
		}
		set {
			self.storage.set(newValue.rawValue, forKey: Keys.language)
		}
	}

	var httpCacheEnabled: Bool {
		get {
			return self.storage.value(forKey: Keys.httpCacheEnabled) ?? false
		}
		set {
			self.storage.set(newValue, forKey: Keys.httpCacheEnabled)
		}
	}

	var httpTimeout: Double {
		get {
			return self.storage.value(forKey: Keys.httpTimeout) ?? Constants.httpTimeoutDefault
		}
		set {
			self.storage.set(newValue, forKey: Keys.httpTimeout)
		}
	}

	var muteOtherSounds: Bool {
		get {
			return self.storage.value(forKey: Keys.muteOtherSounds) ?? true
		}
		set {
			self.storage.set(newValue, forKey: Keys.muteOtherSounds)
			self.onMuteOtherSoundsDidChange?(newValue)
		}
	}
	var onMuteOtherSoundsDidChange: ((Bool) -> Void)?

	var addRoadEventSourceInNavigationView: Bool {
		get {
			return self.storage.value(forKey: Keys.addRoadEventSourceInNavigationView) ?? false
		}
		set {
			self.storage.set(newValue, forKey: Keys.addRoadEventSourceInNavigationView)
		}
	}

	var logLevel: DGis.LogLevel {
		get {
			let rawValue: UInt32? = self.storage.value(forKey: Keys.logLevel)
			return rawValue.flatMap { DGis.LogLevel(rawValue: $0) } ?? .warning
		}
		set {
			self.storage.set(newValue.rawValue, forKey: Keys.logLevel)
		}
	}

	var mapTheme: MapTheme {
		get {
			let rawValue: String? = self.storage.value(forKey: Keys.mapTheme)
			return rawValue.flatMap { MapTheme(rawValue: $0) } ?? .system
		}
		set {
			self.storage.set(newValue.rawValue, forKey: Keys.mapTheme)
		}
	}
	
	var geolocationMarkerType: GeolocationMarkerType {
		get {
			let rawValue: String? = self.storage.value(forKey: Keys.geolocationMarkerType)
			return rawValue.flatMap { GeolocationMarkerType(rawValue: $0) } ?? .model
		}
		set {
			self.storage.set(newValue.rawValue, forKey: Keys.geolocationMarkerType)
		}
	}

	var graphicsOption: GraphicsOption {
		get {
			let rawValue: String? = self.storage.value(forKey: Keys.graphicsOption)
			return rawValue.flatMap { GraphicsOption(rawValue: $0) } ?? .default
		}
		set {
			self.storage.set(newValue.rawValue, forKey: Keys.graphicsOption)
		}
	}

	var navigatorVoiceVolume: UInt32 {
		get {
			return self.storage.value(forKey: Keys.navigatorVoiceVolume) ?? 100
		}
		set {
			self.storage.set(newValue, forKey: Keys.navigatorVoiceVolume)
			self.onNavigatorVoiceVolumeSourceDidChange?(newValue)
		}
	}
	var onNavigatorVoiceVolumeSourceDidChange: ((UInt32) -> Void)?

	var navigatorTheme: NavigatorTheme {
		get {
			let rawValue: String? = self.storage.value(forKey: Keys.navigatorTheme)
			return rawValue.flatMap { NavigatorTheme(rawValue: $0) } ?? .default
		}
		set {
			self.storage.set(newValue.rawValue, forKey: Keys.navigatorTheme)
		}
	}

	var navigatorControls: NavigatorControls {
		get {
			let rawValue: String? = self.storage.value(forKey: Keys.navigatorControls)
			return rawValue.flatMap { NavigatorControls(rawValue: $0) } ?? .default
		}
		set {
			self.storage.set(newValue.rawValue, forKey: Keys.navigatorControls)
		}
	}

	var navigatorDashboardButton: NavigatorDashboardButton {
		get {
			let rawValue: String? = self.storage.value(forKey: Keys.navigatorDashboardButton)
			return rawValue.flatMap { NavigatorDashboardButton(rawValue: $0) } ?? .default
		}
		set {
			self.storage.set(newValue.rawValue, forKey: Keys.navigatorDashboardButton)
		}
	}

	var isMiniMapSelected: Bool {
		get {
			return self.storage.value(forKey: Keys.isMiniMapSelected) ?? true
		}
		set {
			self.storage.set(newValue, forKey: Keys.isMiniMapSelected)
		}
	}

	private let languageSettings: ILanguageSettings
	private let storage: IKeyValueStorage

	init(
		languageSettings: ILanguageSettings,
		storage: IKeyValueStorage
	) {
		self.languageSettings = languageSettings
		self.storage = storage
	}

	func setLanguage(_ language: Language) {
		let oldLanguage = self.currentLanguage
		self.languageSettings.setCurrentLanguage(language)
		guard oldLanguage != self.currentLanguage else { return }
		self.onCurrentLanguageDidChange?()
	}
}
