import CoreLocation
import DGis

class SearchResultViewModel: ObservableObject {
	@Published var items: [SearchResultItemViewModel] = []
	var isEmpty: Bool {
		self.items.isEmpty
	}
	static var empty = SearchResultViewModel()
	private var currentPage: Page? = nil
	private var lastPosition: CLLocation? = nil
	private var isLoadingNextPage = false
	private var nextPageCancellable: DGis.Cancellable?

	init(
		result: SearchResult? = nil,
		lastPosition: CLLocation? = nil
	) {
		self.lastPosition = lastPosition
		self.loadFirstPage(result: result)
	}

	func loadFirstPage(result: SearchResult?) {
		let lastPositionPoint = lastPosition.map { GeoPoint(coordinate: $0.coordinate) }
		self.items = result?.firstPage?.items.compactMap({ ($0, lastPositionPoint) }).map(SearchResultItemViewModel.init) ?? []
		self.currentPage = result?.firstPage
	}

	func loadNextPage() {
		guard let currentPage = self.currentPage, !self.isLoadingNextPage else { return }
		self.isLoadingNextPage = true
		self.nextPageCancellable = currentPage.fetchNextPage().sinkOnMainThread(
			receiveValue: { result in
				self.isLoadingNextPage = false
				switch result {
				case .some(let nextPage):
					let lastPositionPoint = self.lastPosition.map { GeoPoint(coordinate: $0.coordinate) }
					let newItems = nextPage.items.compactMap { ($0, lastPositionPoint) }.map(SearchResultItemViewModel.init)
					self.items.append(contentsOf: newItems)
					self.currentPage = nextPage
				case .none:
					return
				}
			},
			failure: { error in
				print("Failed to load next page: \(error)")
			})
		}
}
