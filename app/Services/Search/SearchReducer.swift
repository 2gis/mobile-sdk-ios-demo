import DGis

final class SearchReducer {
	private let service: SearchService
	private let history: SearchHistoryService

	init(service: SearchService, history: SearchHistoryService) {
		self.service = service
		self.history = history
	}

	func callAsFunction(state: inout SearchState, action: SearchAction) -> ReducerResult {
		var result: ReducerResult = .completed
		switch action {
		case .idle:
			break

		case let .setError(message):
			state.errorMessage = message
			state.isErrorAlertShown = true

		case let .setQueryText(queryText):
			if state.queryText != queryText {
				state.queryText = queryText
				state.rubricIds.removeAll()

				if !queryText.isEmpty {
					self.service.suggestIfNeeded(queryText: queryText)
						.store(in: &result)
				} else {
					self.service.cancelSuggest()
					self.history.items().store(in: &result)

					state.suggestion = .empty
					state.result = .empty
				}
			}

		case .search:
			if state.queryText.isEmpty, state.rubricIds.isEmpty {
				state.result = .empty
				self.history.items().store(in: &result)
			} else {
				self.service.search(
					queryText: state.queryText,
					rubricIds: state.rubricIds,
					searchOptions: state.searchOptions
				)
				.store(in: &result)
			}

		case let .setSearchOptions(options):
			state.searchOptions = options
			if state.queryText.isEmpty, state.rubricIds.isEmpty {
				state.result = .empty
				self.history.items().store(in: &result)
			} else {
				self.service.search(
					queryText: state.queryText,
					rubricIds: state.rubricIds,
					searchOptions: options
				)
				.store(in: &result)
			}

		case let .searchQuery(query, title, subtitle):
			self.service.search(
				query: query,
				title: title,
				subtitle: subtitle,
				addToHistory: true
			)
			.store(in: &result)
			state.history = .empty

		case let .setSearchResult(result):
			state.result = result
			state.suggestion = .empty

		case .resetSuggestions:
			state.suggestion = .empty

		case let .setSuggestResult(suggestion):
			state.suggestion = suggestion
			state.result = .empty

		case let .handleSuggest(suggest):
			self.service.apply(suggest: suggest)
				.store(in: &result)

		case let .applyObjectSuggest(suggest):
			state.navigation = .openSuggest(suggest.id)
			switch suggest.applyHandler {
			case let .objectHandler(handler):
				let historyItem = SearchHistoryItem.directoryObject(handler!.item)
				self.history.addItem(item: historyItem)
				state.history = .empty
			default: fatalError()
			}

		case let .navigate(navigation):
			state.navigation = navigation

		case let .setHistoryResult(historyResult):
			state.history = historyResult
			state.result = .empty

		case .getHistory:
			self.history.items().store(in: &result)

		case .clearHistory:
			self.history.clear()
			state.history = .empty

		case let .handleSearchHistoryItem(itemViewModel):
			let searchHistoryItem = itemViewModel.item
			switch searchHistoryItem {
			case .directoryObject(_):
				self.history.addItem(item: searchHistoryItem)
				guard let objectViewModel = itemViewModel.objectViewModel else {
					fatalError("Search history view model is in an inconsistent internal state.")
				}
				state.navigation = .openDirectoryObject(objectViewModel.id)
			case let .searchQuery(searchQuery):
				self.service.search(
					query: searchQuery.searchQuery,
					title: searchQuery.title,
					subtitle: searchQuery.subtitle,
					addToHistory: true
				)
				.store(in: &result)
			}

		case let .removeSearchHistoryItem(itemViewModel):
			self.history.removeItem(item: itemViewModel.item)
			state.history = .empty
			self.history.items().store(in: &result)
		}

		return result
	}
}

typealias Dispatcher = (SearchAction) -> Void

struct Thunk {
	typealias Body = (@escaping Dispatcher) -> Void
	private var body: Body

	init(body: @escaping Body) {
		self.body = body
	}

	func callAsFunction(_ dispatcher: @escaping Dispatcher) {
		self.body(dispatcher)
	}
}

struct AppliedThunk {
	let thunk: Thunk
	let dispatcher: Dispatcher

	init(thunk: Thunk, dispatcher: @escaping Dispatcher) {
		self.thunk = thunk
		self.dispatcher = dispatcher
	}

	func callAsFunction() {
		self.thunk(self.dispatcher)
	}
}

enum ReducerResult {
	case completed
	case continuation(Thunk)
}

extension Thunk {
	func store(in result: inout ReducerResult) {
		result = .continuation(self)
	}

	func bind(_ dispatcher: @escaping Dispatcher) -> AppliedThunk {
		AppliedThunk(thunk: self, dispatcher: dispatcher)
	}
}

extension ReducerResult {
	func store(in result: inout ReducerResult) {
		result = self
	}
}
