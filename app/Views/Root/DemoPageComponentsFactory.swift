import SwiftUI
import DGis

struct DemoPageComponentsFactory {
	enum MapControlType {
		case zoom
		case currentLocation
	}
	private let mapFactory: IMapFactory
	private let sdk: DGis.Container

	internal init(
		sdk: DGis.Container,
		mapFactory: IMapFactory
	) {
		self.sdk = sdk
		self.mapFactory = mapFactory
	}

	func makeMapView(
		with controls: [MapControlType] = [],
		appearance: MapAppearance? = nil,
		alignment: CopyrightAlignment = .bottomRight,
		mapGesturesType: MapGesturesType? = nil,
		mapCoordinateSpace: String = "map",
		touchUpHandler: ((CGPoint) -> Void)? = nil
	) -> some View {
		ZStack {
			self.makeMapView(appearance: appearance, mapGesturesType: mapGesturesType)
			.copyrightAlignment(alignment)
			.coordinateSpace(name: mapCoordinateSpace)
			.touchUpRecognizer(coordinateSpace: .named(mapCoordinateSpace), handler: { location in
				touchUpHandler?(location)
			})
			if controls.isEmpty == false {
				HStack {
					Spacer()
					VStack {
						if controls.contains(.zoom) {
							self.makeZoomControl()
							.frame(width: 48, height: 104)
							.fixedSize()
						}
						if controls.contains(.currentLocation) {
							self.makeCurrentLocationControl()
							.frame(width: 48, height: 48)
							.fixedSize()
						}
					}
					.padding(.trailing, 10)
				}
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

	func makeCurrentLocationControl() -> some View {
		MapControl(controlFactory: self.mapFactory.mapControlFactory.makeCurrentLocationControl)
	}

	func makeSearchView(searchStore: SearchStore) -> some View {
		return SearchView(store: searchStore)
	}

	func makeMarkerView(viewModel: MarkerViewModel, show: Binding<Bool>) -> some View {
		return MarkerView(viewModel: viewModel, show: show)
	}

	func makeMapObjectCardView(_ viewModel: MapObjectCardViewModel) -> some View {
		return MapObjectCardView(viewModel: viewModel)
	}

	func makeClusterCardView(_ viewModel: ClusterCardViewModel) -> some View {
		return ClusterCardView(viewModel: viewModel)
	}

	private func makeMapView(
		appearance: MapAppearance? = nil,
		mapGesturesType: MapGesturesType? = nil
	) -> MapView {
		MapView(
			appearance: appearance,
			mapGesturesType: mapGesturesType,
			mapUIViewFactory: { [mapFactory = self.mapFactory] in
				mapFactory.mapView
			},
			mapGestureViewFactory: { [mapFactory = self.mapFactory] type in
				let factory: IMapGestureViewFactory?
				switch type {
					case .default:
						factory = MapOptions.default.gestureViewFactory
					case .custom:
						factory = CustomGestureViewFactory()
				}
				return factory?.makeGestureView(
					map: mapFactory.map,
					eventProcessor: mapFactory.mapEventProcessor,
					coordinateSpace: mapFactory.mapCoordinateSpace
				)
			}
		)
	}
}
