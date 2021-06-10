import Combine
import SwiftUI
import PlatformMapSDK

final class SearchService {
	private let searchManagerFactory: () -> ISearchManager
	private let map: Map
	private lazy var searchManager: ISearchManager = self.searchManagerFactory()
	private let schedule: (@escaping () -> Void) -> Void
	private var suggestDebouncer = PassthroughSubject<AppliedThunk, Never>()
	private var sdkCancellable: ICancellable = NoopCancellable()
	private var cancellables: [AnyCancellable] = []

	init<S: Scheduler>(
		searchManagerFactory: @escaping () -> ISearchManager,
		map: Map,
		scheduler: S
	) {
		self.searchManagerFactory = searchManagerFactory
		self.map = map
		self.schedule = scheduler.schedule

		self.suggestDebouncer
			.debounce(for: .milliseconds(250), scheduler: scheduler)
			.receive(on: scheduler)
			.sink(receiveValue: { appliedThunk in appliedThunk() })
			.store(in: &self.cancellables)
	}

	func apply(suggest: SuggestViewModel) -> Thunk {
		Thunk { dispatcher in
			switch suggest.applyHandler {
				case .objectHandler(let handler):
					debugPrint(handler!)
					dispatcher(.applyObjectSuggest(suggest))
				case .performSearchHandler(let handler):
					dispatcher(.searchQuery(handler!.searchQuery))
				case .incompleteTextHandler(let handler):
					dispatcher(.setQueryText(handler!.queryText))
				@unknown default:
					fatalError()
			}
		}
	}

	func suggestIfNeeded(queryText: String) -> Thunk {
		Thunk { [weak self] dispatcher in
			guard let self = self else { return }
			if queryText.isEmpty {
				dispatcher(.resetSuggestions)
				return
			}
			let appliedThunk = self.suggest(queryText: queryText)
				.bind(dispatcher)
			self.suggestDebouncer.send(appliedThunk)
		}
	}

	func search(queryText: String) -> Thunk {
		Thunk { [weak self] dispatcher in
			guard let self = self else { return }

			// Не ищем по пустому запросу.
			guard !queryText.isEmpty else { return }

			let queryText = queryText
			let query = SearchQueryBuilder
				.fromQueryText(queryText: queryText)
				.setAreaOfInterest(rect: self.map.camera.visibleRect)
				.build()
			self.search(query: query)(dispatcher)
		}
	}

	func search(query: SearchQuery) -> Thunk {
		Thunk { [weak self] dispatcher in
			guard let self = self else { return }
			self.sdkCancellable.cancel()

			let future = self.searchManager.search(query: query)
			let cancel = future.sink(receiveValue: {
				[schedule = self.schedule] result in
				schedule {
					let resultViewModel = SearchResultViewModel(result)
					dispatcher(.setSearchResult(resultViewModel))
				}
			}, failure: {
				[schedule = self.schedule] error in
				schedule {
					let message = "Search failed [\(error.localizedDescription)]"
					dispatcher(.setError(message))
				}
			})
			self.sdkCancellable = cancel
		}
	}

	private func suggest(queryText: String) -> Thunk {
		Thunk { [weak self] dispatcher in
			guard let self = self else { return }

			// Не подсказываем по пустому запросу.
			guard !queryText.isEmpty else { return }

			let query = SuggestQueryBuilder
				.fromQueryText(queryText: queryText)
				.setAreaOfInterest(rect: self.map.camera.visibleRect)
				.build()
			self.suggest(query: query)(dispatcher)
		}
	}

	private func suggest(query: SuggestQuery) -> Thunk {
		Thunk { [weak self] dispatcher in
			guard let self = self else { return }

			self.sdkCancellable.cancel()

			let future = self.searchManager.suggest(query: query)
			let cancel = future.sink(receiveValue: {
				[schedule = self.schedule] result in
				schedule {
					let suggestResultViewModel = self.makeSuggestResultViewModel(result: result)
					dispatcher(.setSuggestResult(suggestResultViewModel))
				}
			}, failure: {
				[schedule = self.schedule] error in
				schedule {
					let message = "Search failed [\(error.localizedDescription)]"
					dispatcher(.setError(message))
				}
			})
			self.sdkCancellable = cancel
		}
	}

	private func makeSuggestResultViewModel(
		result: SuggestResult
	) -> SuggestResultViewModel {
		return SuggestResultViewModel(
			result: result
		)
	}
}
