import SwiftUI

struct RootViewFactory {
	private let mapUIViewFactory: () -> UIView
	private let viewModel: RootViewModel

	init(
		viewModel: RootViewModel,
		mapUIViewFactory: @escaping () -> UIView
	) {
		self.viewModel = viewModel
		self.mapUIViewFactory = mapUIViewFactory
	}

	func makeMapView() -> some View {
		MapView(mapUIViewFactory: self.mapUIViewFactory)
	}

	func makeSearchView() -> some View {
		let store = self.viewModel.searchStore
		return SearchView(store: store)
	}
}
