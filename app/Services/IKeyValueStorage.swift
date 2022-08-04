import Foundation

protocol IKeyValueStorage {
	func object(forKey key: String) -> Any?
	func set(_ value: Any?, forKey key: String)
}

extension IKeyValueStorage {
	func value<T>(forKey key: String) -> T? {
		self.object(forKey: key) as? T
	}
}

extension UserDefaults: IKeyValueStorage {}
