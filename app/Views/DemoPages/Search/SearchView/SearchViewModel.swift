import SwiftUI
import Combine
import DGis

final class SearchViewModel: ObservableObject {
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
}
