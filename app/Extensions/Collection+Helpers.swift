import Foundation

extension Collection {
	subscript(safe index: Index) -> Element? {
		guard self.indices.contains(index) else { return nil }
		return self[index]
	}
}
