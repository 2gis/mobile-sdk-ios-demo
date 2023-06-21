import Foundation
import DGis

protocol ISettingsService: AnyObject {
	var onCurrentLanguageDidChange: ((Language) -> Void)? { get set }
	var mapDataSource: MapDataSource { get set }
	var language: Language { get set }
	var httpCacheEnabled: Bool { get set }
	var muteOtherSounds: Bool { get set }
	var addRoadEventSourceInNavigationView: Bool { get set }
	var logLevel: DGis.LogLevel { get set }
	var navigatorVoiceVolumeSource: NavigatorVoiceVolumeSource { get set }
	var navigatorTheme: NavigatorTheme { get set }
}

final class SettingsService: ISettingsService {
	private enum Keys {
		static let mapDataSource = "Global/MapDataSource"
		static let language = "Global/Language"
		static let httpCacheEnabled = "Global/HttpCacheEnabled"
		static let muteOtherSounds = "Global/MuteOtherSounds"
		static let navigatorVoiceVolumeSource = "Global/NavigatorVoiceVolumeSource"
		static let navigatorTheme = "Global/NavigatorTheme"
		static let addRoadEventSourceInNavigationView = "Global/AddRoadEventSourceInNavigationView"
		static let logLevel = "Global/LogLevel"
	}

	var onCurrentLanguageDidChange: ((Language) -> Void)?

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

	var navigatorVoiceVolumeSource: NavigatorVoiceVolumeSource {
		get {
			let rawValue: String? = self.storage.value(forKey: Keys.navigatorVoiceVolumeSource)
			return rawValue.flatMap { NavigatorVoiceVolumeSource(rawValue: $0) } ?? .high
		}
		set {
			self.storage.set(newValue.rawValue, forKey: Keys.navigatorVoiceVolumeSource)
			let volume = AudioVolume(newValue)
			self.onNavigatorVoiceVolumeSourceDidChange?(volume)
		}
	}
	var onNavigatorVoiceVolumeSourceDidChange: ((AudioVolume) -> Void)?

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

	private let storage: IKeyValueStorage

	init(
		storage: IKeyValueStorage
	) {
		self.storage = storage
	}
}
