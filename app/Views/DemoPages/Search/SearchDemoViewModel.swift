import SwiftUI
import Combine
import PlatformMapSDK

final class SearchDemoViewModel: ObservableObject {
	let searchStore: SearchStore

	private let searchManagerFactory: () -> SearchManager
	private let map: Map

	init(searchManagerFactory: @escaping () -> SearchManager, map: Map) {
		self.searchManagerFactory = searchManagerFactory
		self.map = map
		let service = SearchService(
			searchManagerFactory: self.searchManagerFactory,
			map: self.map,
			scheduler: DispatchQueue.main
		)
		let reducer = SearchReducer(service: service)
		self.searchStore = SearchStore(initialState: .init(), reducer: reducer)
	}

	func makeSearchViewModel() -> SearchViewModel {
		let service = SearchService(
			searchManagerFactory: self.searchManagerFactory,
			map: self.map,
			scheduler: DispatchQueue.main
		)
		let viewModel = SearchViewModel(
			searchStore: self.searchStore,
			searchService: service
		)
		return viewModel
	}
}
