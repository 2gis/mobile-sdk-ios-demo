import SwiftUI
import PlatformSDK

struct RootViewFactory {
	private let mapUIViewFactory: () -> UIView
	private let mapControlFactory: IMapControlFactory
	private let viewModel: RootViewModel
	private let markerViewModel: MarkerViewModel

	init(
		viewModel: RootViewModel,
		markerViewModel: MarkerViewModel,
		mapUIViewFactory: @escaping () -> UIView,
		mapControlFactory: IMapControlFactory
	) {
		self.viewModel = viewModel
		self.markerViewModel = markerViewModel
		self.mapUIViewFactory = mapUIViewFactory
		self.mapControlFactory = mapControlFactory
	}

	func makeMapView() -> some View {
		MapView(mapUIViewFactory: self.mapUIViewFactory)
	}

	func makeZoomControl() -> some View {
		ZoomControl(controlFactory: self.mapControlFactory.makeZoomControl)
	}

	func makeSearchView() -> some View {
		let store = self.viewModel.searchStore
		return SearchView(store: store)
	}

	func makeMarkerView(show: Binding<Bool>) -> some View {
		return MarkerView(viewModel: self.markerViewModel, show: show)
	}
}
