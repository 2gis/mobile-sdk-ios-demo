import SwiftUI
import Combine
import PlatformMapSDK

final class SearchDemoViewModel: ObservableObject {
	let searchStore: SearchStore

	private let searchManagerFactory: () -> SearchManager

	init(searchManagerFactory: @escaping () -> SearchManager) {
		self.searchManagerFactory = searchManagerFactory
		let service = SearchService(
			searchManagerFactory: self.searchManagerFactory,
			scheduler: DispatchQueue.main
		)
		let reducer = SearchReducer(service: service)
		self.searchStore = SearchStore(initialState: .init(), reducer: reducer)
	}

	func makeSearchViewModel() -> SearchViewModel {
		let service = SearchService(
			searchManagerFactory: self.searchManagerFactory,
			scheduler: DispatchQueue.main
		)
		let viewModel = SearchViewModel(
			searchStore: self.searchStore,
			searchService: service
		)
		return viewModel
	}
}
