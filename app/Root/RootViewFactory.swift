import SwiftUI
import PlatformSDK

struct RootViewFactory {
	private let viewModel: RootViewModel
	private let markerViewModel: MarkerViewModel
	private let routeViewModel: RouteViewModel
	private let mapUIViewFactory: () -> UIView
	private let mapControlFactory: IMapControlFactory

	init(
		viewModel: RootViewModel,
		markerViewModel: MarkerViewModel,
		routeViewModel: RouteViewModel,
		mapUIViewFactory: @escaping () -> UIView,
		mapControlFactory: IMapControlFactory
	) {
		self.viewModel = viewModel
		self.markerViewModel = markerViewModel
		self.routeViewModel = routeViewModel
		self.mapUIViewFactory = mapUIViewFactory
		self.mapControlFactory = mapControlFactory
	}

	func makeMapView() -> some View {
		MapView(mapUIViewFactory: self.mapUIViewFactory)
	}

	func makeZoomControl() -> some View {
		MapControl(controlFactory: self.mapControlFactory.makeZoomControl)
	}

	func makeSearchView() -> some View {
		let store = self.viewModel.searchStore
		return SearchView(store: store)
	}

	func makeMarkerView(show: Binding<Bool>) -> some View {
		return MarkerView(viewModel: self.markerViewModel, show: show)
	}

	func makeRouteView(show: Binding<Bool>) -> some View {
		return RouteView(viewModel: self.routeViewModel, show: show)
	}
}
