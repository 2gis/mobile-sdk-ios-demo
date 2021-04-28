import SwiftUI
import PlatformSDK

struct RootViewFactory {
	private let viewModel: RootViewModel
	private let markerViewModel: MarkerViewModel
	private let routeViewModel: RouteViewModel
	private let mapUIViewFactory: () -> UIView & IMapView
	private let mapControlFactory: IMapControlFactory

	init(
		viewModel: RootViewModel,
		markerViewModel: MarkerViewModel,
		routeViewModel: RouteViewModel,
		mapUIViewFactory: @escaping () -> UIView & IMapView,
		mapControlFactory: IMapControlFactory
	) {
		self.viewModel = viewModel
		self.markerViewModel = markerViewModel
		self.routeViewModel = routeViewModel
		self.mapUIViewFactory = mapUIViewFactory
		self.mapControlFactory = mapControlFactory
	}

	func makeMapView() -> MapView {
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

	func makeMapObjectCardView(_ viewModel: MapObjectCardViewModel) -> some View {
		return MapObjectCardView(viewModel: viewModel)
	}
}
