import Foundation

protocol INavigatorSettings: AnyObject {
	var voiceId: String? { get set }
}

final class NavigatorSettings: INavigatorSettings {
	private enum Keys {
		static let voiceId = "Navigator/VoiceId"
	}
	private let storage: IKeyValueStorage

	init(storage: IKeyValueStorage) {
		self.storage = storage
	}

	var voiceId: String? {
		get {
			self.storage.value(forKey: Keys.voiceId)
		}
		set {
			self.storage.set(newValue, forKey: Keys.voiceId)
		}
	}
}
