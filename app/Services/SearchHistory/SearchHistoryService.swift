import Combine
import DGis

final class SearchHistoryService: @unchecked Sendable {
	private let searchHistory: SearchHistory
	private var historyCancellable: ICancellable = NoopCancellable()

	init(searchHistory: SearchHistory) {
		self.searchHistory = searchHistory
	}

	func addItem(item: SearchHistoryItem) {
		self.historyCancellable.cancel()
		self.searchHistory.addItem(item: item)
	}

	func removeItem(item: SearchHistoryItem) {
		self.historyCancellable.cancel()
		self.searchHistory.removeItem(item: item)
	}

	func items() -> Thunk {
		Thunk { [weak self] dispatcher in
			guard let self else { return }

			self.historyCancellable.cancel()

			let future = self.searchHistory.items(page: SearchHistoryPage())
			self.historyCancellable = future.sinkOnMainThread(receiveValue: { result in
				Task { @MainActor in
					dispatcher(.setHistoryResult(SearchHistoryViewModel(items: result.items)))
				}
			}, failure: { _ in })
		}
	}

	func clear() {
		self.searchHistory.clear()
	}
}
