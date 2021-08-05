import Foundation
import SwiftUI
import DGis

struct SuggestResultViewModel {
	let suggests: [SuggestViewModel]

	var isEmpty: Bool {
		self.suggests.isEmpty
	}

	init(
		result: SuggestResult? = nil
	) {
		self.suggests = result?.suggests.compactMap { suggest in
			switch suggest.handler {
				case .objectHandler, .incompleteTextHandler:
					return SuggestViewModel(suggest: suggest)
				case .performSearchHandler:
					return nil
				@unknown default:
					return nil
			}
		} ?? []
	}
}

extension SuggestResultViewModel {
	static var empty = Self()
}
