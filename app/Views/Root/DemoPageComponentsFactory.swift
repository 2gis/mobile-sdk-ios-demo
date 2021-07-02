import SwiftUI
import DGis

struct DemoPageComponentsFactory {
	private let mapFactory: IMapFactory
	private let sdk: DGis.Container

	internal init(
		sdk: DGis.Container,
		mapFactory: IMapFactory
	) {
		self.sdk = sdk
		self.mapFactory = mapFactory
	}

	func makeMapView(appearance: MapAppearance? = nil) -> MapView {
		MapView(appearance: appearance, mapUIViewFactory: { [mapFactory = self.mapFactory] in
			mapFactory.mapView
		})
	}

	func makeMapViewWithZoomControl(
		alignment: CopyrightAlignment = .bottomRight,
		mapCoordinateSpace: String = "map",
		touchUpHandler: ((CGPoint) -> Void)? = nil
	) -> some View {
		ZStack {
			self.makeMapView()
				.copyrightAlignment(alignment)
				.coordinateSpace(name: mapCoordinateSpace)
				.touchUpRecognizer(coordinateSpace: .named(mapCoordinateSpace), handler: { location in
					touchUpHandler?(location)
				})
			HStack {
				Spacer()
				self.makeZoomControl()
					.frame(width: 60, height: 128)
					.fixedSize()
					.transformEffect(.init(scaleX: 0.8, y: 0.8))
					.padding(10)
			}
		}
	}

	func makeZoomControl() -> some View {
		MapControl(controlFactory: self.mapFactory.mapControlFactory.makeZoomControl)
	}

	func makeCustomControl() -> some View {
		MapControl(controlFactory: { [mapFactory = self.mapFactory] in
			CustomZoomControl(map: mapFactory.map)
		})
	}

	func makeSearchView(searchStore: SearchStore) -> some View {
		return SearchView(store: searchStore)
	}

	func makeMarkerView(viewModel: MarkerViewModel, show: Binding<Bool>) -> some View {
		return MarkerView(viewModel: viewModel, show: show)
	}

	func makeRouteView(show: Binding<Bool>) -> some View {
		let viewModel = RouteViewModel(
			sourceFactory: { [sdk = self.sdk] in
				sdk.sourceFactory
			},
			routeEditorSourceFactory: { [sdk = self.sdk] routeEditor in
				return RouteEditorSource(context: sdk.context, routeEditor: routeEditor)
			},
			routeEditorFactory: { [sdk = self.sdk] in
				return RouteEditor(context: sdk.context)
			},
			map: self.mapFactory.map
		)
		return RouteView(viewModel: viewModel, show: show)
	}

	func makeMapObjectCardView(_ viewModel: MapObjectCardViewModel) -> some View {
		return MapObjectCardView(viewModel: viewModel)
	}
}
