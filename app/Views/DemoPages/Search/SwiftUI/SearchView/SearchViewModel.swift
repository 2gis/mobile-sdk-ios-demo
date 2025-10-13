import Combine
import DGis
import SwiftUI

@MainActor
final class SearchViewModel: @preconcurrency ObservableObject, @unchecked Sendable {
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

		self.store.dispatch(.getHistory)
	}
}
