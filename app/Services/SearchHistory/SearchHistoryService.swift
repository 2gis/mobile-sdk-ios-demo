import Combine
import DGis

final class SearchHistoryService {
	private let searchHistory: SearchHistory
	private var historyCancellable: ICancellable = NoopCancellable()

	private let schedule: (@escaping () -> Void) -> Void

	init<S: Scheduler>(
		searchHistory: SearchHistory,
		scheduler: S
	) {
		self.searchHistory = searchHistory
		self.schedule = scheduler.schedule
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
			guard let self = self else { return }

			self.historyCancellable.cancel()

			let future = self.searchHistory.items(page: SearchHistoryPage())
			self.historyCancellable = future.sink(receiveValue: {
				[schedule = self.schedule] result in
				schedule {
					dispatcher(.setHistoryResult(SearchHistoryViewModel(items: result.items)))
				}
			}, failure: { _ in })
		}
	}

	func clear() {
		self.searchHistory.clear()
	}
}
