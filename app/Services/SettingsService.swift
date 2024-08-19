import Foundation
import DGis

protocol ISettingsService: AnyObject {
	var onCurrentLanguageDidChange: ((Language) -> Void)? { get set }
	var customStyleUrl: URL? { get set }
	var mapDataSource: MapDataSource { get set }
	var language: Language { get set }
	var httpCacheEnabled: Bool { get set }
	var muteOtherSounds: Bool { get set }
	var addRoadEventSourceInNavigationView: Bool { get set }
	var logLevel: DGis.LogLevel { get set }
	var mapTheme: MapTheme { get set }
	var navigatorVoiceVolume: UInt32 { get set }
	var navigatorTheme: NavigatorTheme { get set }
	var graphicsOption: GraphicsOption { get set }
}

final class SettingsService: ISettingsService {
	private enum Keys {
		static let customStyleURL = "Global/CustomStyleURL"
		static let mapDataSource = "Global/MapDataSource"
		static let language = "Global/Language"
		static let httpCacheEnabled = "Global/HttpCacheEnabled"
		static let muteOtherSounds = "Global/MuteOtherSounds"
		static let addRoadEventSourceInNavigationView = "Global/AddRoadEventSourceInNavigationView"
		static let logLevel = "Global/LogLevel"
		static let mapTheme = "Global/MapTheme"
		static let navigatorVoiceVolume = "Global/NavigatorVoiceVolume"
		static let navigatorTheme = "Global/NavigatorTheme"
		static let graphicsOption = "Global/GraphicsOption"
	}

	var onCurrentLanguageDidChange: ((Language) -> Void)?

	var customStyleUrl: URL? {
		get {
			let rawValue: String? = self.storage.value(forKey: Keys.customStyleURL)
			return rawValue.flatMap { URL(string: $0) } ?? nil
		}
		set {
			self.storage.set(newValue?.absoluteString ?? nil, forKey: Keys.customStyleURL)
		}
	}

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
			self.onCurrentLanguageDidChange?(newValue)
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
			return rawValue.flatMap { MapTheme(rawValue: $0) } ?? .default
		}
		set {
			self.storage.set(newValue.rawValue, forKey: Keys.mapTheme)
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

	private let storage: IKeyValueStorage

	init(
		storage: IKeyValueStorage
	) {
		self.storage = storage
	}
}
