import PlatformMapSDK

struct SearchResultViewModel {
	let items: [SearchResultItemViewModel]

	var isEmpty: Bool {
		self.items.isEmpty
	}

	init(_ result: SearchResult? = nil) {
		self.items = result?.firstPage?.items.compactMap({ $0 }).map(SearchResultItemViewModel.init) ?? []
	}
}

extension SearchResultViewModel {
	static var empty = Self()
}
