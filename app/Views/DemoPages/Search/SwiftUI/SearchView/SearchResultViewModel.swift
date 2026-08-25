import Combine
import CoreLocation
import DGis

@MainActor
class SearchResultViewModel: ObservableObject {
	var isEmpty: Bool {
		self.objects.isEmpty
	}

	static let empty = SearchResultViewModel()

	@Published var objects: [DirectoryObject] = []
	private var currentPage: Page? = nil
	private(set) var lastPosition: GeoPoint? = nil
	private var isLoadingNextPage = false
	private var nextPageCancellable: DGis.Cancellable?

	init(
		result: SearchResult? = nil,
		lastPosition: CLLocation? = nil
	) {
		self.lastPosition = lastPosition.map {
			GeoPoint(
				latitude: $0.coordinate.latitude,
				longitude: $0.coordinate.longitude
			)
		}
		self.loadFirstPage(result: result)
	}

	func loadFirstPage(result: SearchResult?) {
		self.objects = result?.firstPage?.items ?? []
		self.currentPage = result?.firstPage
	}

	func loadNextPage() {
		guard let currentPage = self.currentPage, !self.isLoadingNextPage else { return }
		self.isLoadingNextPage = true
		self.nextPageCancellable = currentPage.fetchNextPage().sinkOnMainThread(
			receiveValue: { result in
				Task { @MainActor in
					self.isLoadingNextPage = false
					switch result {
					case let .some(nextPage):
						let newObjects = nextPage.items
						self.objects.append(contentsOf: newObjects)
						self.currentPage = nextPage
					case .none:
						return
					@unknown default:
						assertionFailure("Unknown value for fetchNextPage Futute result")
					}
				}
			},
			failure: { error in
				print("Failed to load next page: \(error)")
			}
		)
	}
}
