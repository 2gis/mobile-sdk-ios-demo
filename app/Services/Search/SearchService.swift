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
    private let searchHistory: SearchHistoryService
	private let map: Map
	private let objectManager: MapObjectManager
	private let imageFactory: IImageFactory
	private let logger: ILogger
	private let locationService: DGis.LocationService
	private let schedule: (@escaping () -> Void) -> Void
	private var suggestDebouncer = PassthroughSubject<AppliedThunk, Never>()
	private var suggestCancellable: ICancellable = NoopCancellable()
	private var searchCancellable: ICancellable?
	private var searchMarkersCancellable: ICancellable?
	private var cancellables: [AnyCancellable] = []
	private var searchMarkers: [DgisObjectId:Marker] = [:]
	private var markerInfoCancellable: [DGis.Cancellable] = []
    private var isDebouncerActive: Bool = true

	init<S: Scheduler>(
		searchManager: ISearchManager,
        searchHistory: SearchHistoryService,
		map: Map,
		imageFactory: IImageFactory,
		logger: ILogger,
		locationService: DGis.LocationService,
		scheduler: S
	) {
		self.searchManager = searchManager
        self.searchHistory = searchHistory
		self.map = map
		self.imageFactory = imageFactory
		self.logger = logger
		self.objectManager = MapObjectManager.withGeneralization(
			map: self.map,
			logicalPixel: 80.0,
			maxZoom: self.map.camera.zoomRestrictions.maxZoom,
			minZoom: self.map.camera.zoomRestrictions.minZoom)

		self.locationService = locationService
		self.schedule = scheduler.schedule

		self.suggestDebouncer
			.debounce(for: .milliseconds(250), scheduler: scheduler)
            .filter { [weak self] _ in self?.isDebouncerActive == true }
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
                    dispatcher(.searchQuery(handler!.searchQuery, suggest.title.text, suggest.subtitle.text))
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
            self.isDebouncerActive = true
			self.suggestDebouncer.send(appliedThunk)
		}
	}

    func cancelSuggest() {
        self.suggestCancellable.cancel()
        self.isDebouncerActive = false
    }

	func search(
		queryText: String,
		rubricIds: [RubricId],
		searchOptions: SearchOptions?
	) -> Thunk {
		Thunk { [weak self] dispatcher in
			guard let self = self else { return }

			guard !queryText.isEmpty || !rubricIds.isEmpty else { return }

			let queryText = queryText
			let builder: SearchQueryBuilder
			if !rubricIds.isEmpty {
				if !queryText.isEmpty {
					builder = .fromQueryTextAndRubricIds(
						queryText: queryText,
						rubricIds: rubricIds
					)
				} else {
					builder = .fromRubricIds(rubricIds: rubricIds)
				}
			} else {
				builder = .fromQueryText(queryText: queryText)
			}

			let query = builder
				.setAreaOfInterest(rect: self.map.camera.visibleRect)
				.apply(searchOptions: searchOptions)
				.build()
			self.lastSearchQuery = query
            self.search(query: query, title: queryText, subtitle: "", addToHistory: true)(dispatcher)
		}
	}

    func search(query: SearchQuery, title: String, subtitle: String, addToHistory: Bool) -> Thunk {
		Thunk { [weak self] dispatcher in
			guard let self = self else { return }
			self.searchCancellable?.cancel()
            self.cancelSuggest()

            if addToHistory {
                let titledQuery = SearchQueryWithInfo(searchQuery: query, title: title, subtitle: subtitle)
                self.searchHistory.addItem(item: SearchHistoryItem.searchQuery(titledQuery))
            }

			let future = self.searchManager.search(query: query)
			self.searchCancellable = future.sink(receiveValue: {
				[schedule = self.schedule, locationService = self.locationService] result in
				self.searchCancellable = nil
				schedule {
					self.getSearchMarkers(result: result)
					let resultViewModel = self.makeSearchResultViewModel(
						result: result,
						lastPosition: locationService.lastLocation.map({ CLLocation(location: $0) })
					)
					dispatcher(.setSearchResult(resultViewModel))
				}
			}, failure: {
				[schedule = self.schedule] error in
				self.searchCancellable = nil
				schedule {
					let message = "Search failed [\(error.description)]"
					dispatcher(.setError(message))
				}
			})
		}
	}

	private func suggest(queryText: String) -> Thunk {
		Thunk { [weak self] dispatcher in
			guard let self = self else { return }

			// Предыдущий поиск должен быть завершен.
			guard self.searchCancellable == nil else { return }

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

			self.suggestCancellable.cancel()

			let future = self.searchManager.suggest(query: query)
			self.suggestCancellable = future.sink(receiveValue: {
				[schedule = self.schedule, locationService = self.locationService] result in
				schedule {
					let suggestResultViewModel = self.makeSuggestResultViewModel(
						result: result,
						lastPosition: locationService.lastLocation.map({ CLLocation(location: $0) })
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

	private func getSearchMarkers(result: SearchResult) {
		self.searchMarkersCancellable = result.itemMarkerInfos.sink { [weak self] markers in
			guard let self = self,
				  let markersInfo = markers
			else { return }
			self.deleteOldMarkersAndAddNew(markersInfo: markersInfo)
		} failure: { error in
			self.logger.error("Something went wrong: \(error.localizedDescription)")
			self.searchCancellable = nil
		}
	}

	private func deleteOldMarkersAndAddNew(markersInfo: [ItemMarkerInfo]) {
		self.objectManager.removeAll()
		guard let iconImage = createColoredImage(
			systemName: "circle.circle.fill",
			color: .blue
		) else { return }
		let icon = self.imageFactory.make(image: iconImage)
		let markerOptions = markersInfo.filter { $0.objectId != nil }.map { markerInfo in
			MarkerOptions(
				position: markerInfo.geoPoint,
				icon: icon,
                text: markerInfo.title,
				textStyle: .init(
					fontSize: 12.0,
					color: .init(.label)!,
					strokeWidth: 2.0,
					strokeColor: .init(.systemBackground)!,
					textPlacement: .rightCenter,
					textOffset: 0.0
				),
				iconWidth: 27.0,
				userData: markerInfo.objectId!
			)
		}
		self.searchMarkers.removeAll()
		self.createMarkers(options: markerOptions).forEach { marker in
			self.searchMarkers[marker.userData as! DgisObjectId] = marker
		}
		self.objectManager.addObjects(objects: searchMarkers.map {$0.value})
	}

	private func createMarkers(options: [MarkerOptions]) -> [Marker] {
		var markers: [Marker] = []
		options.forEach { option in
			do {
				let marker = try Marker(options: option)
				markers.append(marker)
			} catch let error as SimpleError {
				self.logger.error("Failed to create marker: \(error.description)")
			} catch {
				self.logger.error("Failed to create marker: \(error.localizedDescription)")
			}
		}
		return markers
	}

	private func createColoredImage(systemName: String, color: UIColor) -> UIImage? {
		UIImage(systemName: systemName)?.withTintColor(color, renderingMode: .alwaysOriginal)
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

private extension String {
	func reduce() -> String {
		if let index = self.firstIndex(of: ",") {
			let substring = self[..<index]
			let result = String(substring)
			return result
		} else {
			return self
		}
	}
}
