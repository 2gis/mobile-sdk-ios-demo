import SwiftUI
import Combine
import PlatformSDK

final class SearchViewModel: ObservableObject {
	/*var queryText: Binding<String> {
		self.$store.queryText
	}
	var selection: Binding<SuggestViewModel?> {
		self.$store.selection
	}
	var suggestion: SuggestResultViewModel {
		self.store.suggestion
	}
	var result: SearchResultViewModel {
		self.store.result
	}
	var navigation: Binding<SearchNavigation?> {
		self.$store.navigation
	}*/

	@ObservedObject private var store: SearchStore
	private let searchService: SearchService
	private(set) var objectWillChange: ObservableObjectPublisher

	init(
		searchStore: SearchStore,
		searchService: SearchService
	) {
		self.store = searchStore
		self.searchService = searchService
		self.objectWillChange = searchStore.objectWillChange
	}

	/*func search() {
		self.searchService.search()
	}*/
}
