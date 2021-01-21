import SwiftUI

struct RootViewFactory {
	private let mapUIViewFactory: () -> UIView
	private let viewModel: RootViewModel
	private let markerViewModel: MarkerViewModel

	init(
		viewModel: RootViewModel,
		markerViewModel: MarkerViewModel,
		mapUIViewFactory: @escaping () -> UIView
	) {
		self.viewModel = viewModel
		self.markerViewModel = markerViewModel
		self.mapUIViewFactory = mapUIViewFactory
	}

	func makeMapView() -> some View {
		MapView(mapUIViewFactory: self.mapUIViewFactory)
	}

	func makeSearchView() -> some View {
		let store = self.viewModel.searchStore
		return SearchView(store: store)
	}

	func makeMarkerView(show: Binding<Bool>) -> some View {
		return MarkerView(viewModel: self.markerViewModel, show: show)
	}
}
