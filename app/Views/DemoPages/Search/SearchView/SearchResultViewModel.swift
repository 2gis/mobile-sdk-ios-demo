import CoreLocation
import DGis

struct SearchResultViewModel {
	let items: [SearchResultItemViewModel]

	var isEmpty: Bool {
		self.items.isEmpty
	}

	init(
		result: SearchResult? = nil,
		lastPosition: CLLocation? = nil
	) {
		let lastPositionPoint = lastPosition.map { GeoPoint(coordinate: $0.coordinate) }
		self.items = result?.firstPage?.items.compactMap({ ($0, lastPositionPoint) }).map(SearchResultItemViewModel.init) ?? []
	}
}

extension SearchResultViewModel {
	static var empty = Self()
}
