final class SearchReducer {
	private let service: SearchService

	init(service: SearchService) {
		self.service = service
	}

	func callAsFunction(state: inout SearchState, action: SearchAction) -> ReducerResult {
		var result: ReducerResult = .completed
		switch action {
			case .idle:
				break

			case .setError(let message):
				state.errorMessage = message
				state.isErrorAlertShown = true

			case .setQueryText(let queryText):
				if state.queryText != queryText {
					state.queryText = queryText
					self.service.suggestIfNeeded(queryText: queryText)
						.store(in: &result)
				}

			case .search:
				self.service.search(queryText: state.queryText, searchOptions: state.searchOptions)
					.store(in: &result)

			case .setSearchOptions(let options):
				state.searchOptions = options
				if !state.queryText.isEmpty {
					self.service.search(queryText: state.queryText, searchOptions: options)
						.store(in: &result)
				}

			case .searchQuery(let query):
				self.service.search(query: query)
					.store(in: &result)

			case .setSearchResult(let result):
				state.result = result
				state.suggestion = .empty

			case .resetSuggestions:
				state.suggestion = .empty

			case .setSuggestResult(let suggestion):
				state.suggestion = suggestion
				state.result = .empty

			case .handleSuggest(let suggest):
				self.service.apply(suggest: suggest)
					.store(in: &result)

			case .applyObjectSuggest(let suggest):
				state.navigation = .openSuggest(suggest.id)

			case .navigate(let navigation):
				state.navigation = navigation
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
