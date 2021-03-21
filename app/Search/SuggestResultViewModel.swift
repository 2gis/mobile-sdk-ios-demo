import Foundation
import SwiftUI
import PlatformSDK

struct SuggestResultViewModel {
	let suggests: [SuggestViewModel]

	var isEmpty: Bool {
		self.suggests.isEmpty
	}

	init(
		result: SuggestResult? = nil
	) {
		self.suggests = result?.suggests.compactMap({ $0 }).map(SuggestViewModel.init) ?? []
	}
}

extension SuggestResultViewModel {
	static var empty = Self()
}
