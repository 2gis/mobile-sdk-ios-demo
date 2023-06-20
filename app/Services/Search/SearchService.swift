import Combine
import CoreLocation
import SwiftUI
import DGis

struct SearchOptions {
	struct Filter {
		var directoryFilter: DirectoryFilter?
		var allowedResultTypes: [ObjectType]
	}

	let minPageSize: Int32 = 1
	let maxPageSize: Int32 = 50
	var pageSize: Int32 = 10

	var sortingType: SortingType = .byRelevance
	var filter: Filter = Filter(allowedResultTypes: ObjectType.defaultTypes)
}

final class SearchService {
	var lastSearchQuery: SearchQuery? = nil

	private let searchManager: ISearchManager
	private let map: Map
	private let locationService: DGis.ILocationService
	private let schedule: (@escaping () -> Void) -> Void
	private var suggestDebouncer = PassthroughSubject<AppliedThunk, Never>()
	private var suggestCancellable: ICancellable = NoopCancellable()
	private var searchCancellable: ICancellable?
	private var cancellables: [AnyCancellable] = []

	init<S: Scheduler>(
		searchManager: ISearchManager,
		map: Map,
		locationService: DGis.ILocationService,
		scheduler: S
	) {
		self.searchManager = searchManager
		self.map = map
		self.locationService = locationService
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

	func search(queryText: String, searchOptions: SearchOptions?) -> Thunk {
		Thunk { [weak self] dispatcher in
			guard let self = self else { return }

			// Do not search with empty query text.
			guard !queryText.isEmpty else { return }

			let queryText = queryText
			let query = SearchQueryBuilder
				.fromQueryText(queryText: queryText)
				.setAreaOfInterest(rect: self.map.camera.visibleRect)
				.apply(searchOptions: searchOptions)
				.build()
			self.lastSearchQuery = query
			self.search(query: query)(dispatcher)
		}
	}

	func search(query: SearchQuery) -> Thunk {
		Thunk { [weak self] dispatcher in
			guard let self = self else { return }
			self.searchCancellable?.cancel()

			let future = self.searchManager.search(query: query)
			self.searchCancellable = future.sink(receiveValue: {
				[schedule = self.schedule, locationService = self.locationService] result in
				self.searchCancellable = nil
				schedule {
					let resultViewModel = self.makeSearchResultViewModel(
						result: result,
						lastPosition: locationService.lastLocation
					)
					dispatcher(.setSearchResult(resultViewModel))
				}
			}, failure: {
				[schedule = self.schedule] error in
				self.searchCancellable = nil
				schedule {
					let message = "Search failed [\(error.localizedDescription)]"
					dispatcher(.setError(message))
				}
			})
		}
	}

	private func suggest(queryText: String) -> Thunk {
		Thunk { [weak self] dispatcher in
			guard let self = self else { return }

			// Previous searching must be finished.
			guard self.searchCancellable == nil else { return }

			// Do not suggest with empty query text.
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
			self.suggestCancellable.cancel()

			let future = self.searchManager.suggest(query: query)
			self.suggestCancellable = future.sink(receiveValue: {
				[schedule = self.schedule, locationService = self.locationService] result in
				schedule {
					let suggestResultViewModel = self.makeSuggestResultViewModel(
						result: result,
						lastPosition: locationService.lastLocation
					)
					dispatcher(.setSuggestResult(suggestResultViewModel))
				}
			}, failure: {
				[schedule = self.schedule] error in
				schedule {
					let message = "Search failed [\(error.description)]"
					dispatcher(.setError(message))
				}
			})
		}
	}

	private func makeSearchResultViewModel(
		result: SearchResult,
		lastPosition: CLLocation?
	) -> SearchResultViewModel {
		return SearchResultViewModel(
			result: result,
			lastPosition: lastPosition
		)
	}

	private func makeSuggestResultViewModel(
		result: SuggestResult,
		lastPosition: CLLocation?
	) -> SuggestResultViewModel {
		return SuggestResultViewModel(
			result: result,
			lastPosition: lastPosition
		)
	}
}

private extension SearchQueryBuilder {
	func apply(searchOptions: SearchOptions?) -> SearchQueryBuilder {
		var builder = self
		if let searchOptions = searchOptions {
			if let directoryFilter = searchOptions.filter.directoryFilter {
				builder = builder.setDirectoryFilter(filter: directoryFilter)
			}
			builder = builder.setSortingType(sortingType: searchOptions.sortingType)
			builder = builder.setAllowedResultTypes(allowedResultTypes: searchOptions.filter.allowedResultTypes)
			builder = builder.setPageSize(pageSize: searchOptions.pageSize)
		}
		return builder
	}
}
