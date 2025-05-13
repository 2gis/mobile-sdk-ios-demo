import SwiftUI
import DGis

struct DemoPageComponentsFactory {
	private let sdk: DGis.Container
	private let context: Context
	private let mapFactory: IMapFactory
	private let settingsService: ISettingsService

	internal init(
		sdk: DGis.Container,
		context: Context,
		mapFactory: IMapFactory,
		settingsService: ISettingsService
	) {
		self.sdk = sdk
		self.context = context
		self.mapFactory = mapFactory
		self.settingsService = settingsService
	}

	func makeMapView(
		appearance: MapAppearance? = nil,
		alignment: CopyrightAlignment = .bottomRight,
		mapGesturesType: MapGesturesType = .default(.event),
		copyrightInsets: UIEdgeInsets = .zero,
		showsAPIVersion: Bool = true,
		overlayFactory: IMapViewOverlayFactory? = nil,
		tapRecognizerCallback: MapView.TapRecognizerCallback? = nil,
		markerViewOverlay: IMarkerViewOverlay? = nil
	) -> MapView {
		MapView(
			mapGesturesType: mapGesturesType,
			appearance: appearance,
			copyrightInsets: copyrightInsets,
			copyrightAlignment: alignment,
			showsAPIVersion: showsAPIVersion,
			overlayFactory: overlayFactory,
			tapRecognizerCallback: tapRecognizerCallback,
			mapUIViewFactory: { [mapFactory = self.mapFactory] in
				mapFactory.mapView
			},
			markerViewOverlay: markerViewOverlay
		)
	}

	func makeMapViewWithZoomControl(
		appearance: MapAppearance? = nil,
		alignment: CopyrightAlignment = .bottomRight,
		mapGesturesType: MapGesturesType = .default(.event),
		copyrightInsets: UIEdgeInsets = .zero,
		showsAPIVersion: Bool = true,
		tapRecognizerCallback: MapView.TapRecognizerCallback? = nil
	) -> some View {
		ZStack {
			self.makeMapView(
				appearance: appearance,
				alignment: alignment,
				copyrightInsets: copyrightInsets,
				showsAPIVersion: showsAPIVersion,
				tapRecognizerCallback: tapRecognizerCallback
			)
			HStack {
				Spacer()
				self.makeZoomControl()
				.frame(width: 48, height: 102)
				.fixedSize()
				.padding(10)
			}
		}
	}

	func makeMapViewWithMarkerViewOverlay(
		appearance: MapAppearance? = nil,
		alignment: CopyrightAlignment = .bottomRight,
		copyrightInsets: UIEdgeInsets = .zero,
		showsAPIVersion: Bool = true,
		overlayFactory: IMapViewOverlayFactory? = nil,
		tapRecognizerCallback: MapView.TapRecognizerCallback? = nil
	) -> MapView {
		self.makeMapView(
			appearance: appearance,
			alignment: alignment,
			copyrightInsets: copyrightInsets,
			showsAPIVersion: showsAPIVersion,
			overlayFactory: overlayFactory,
			tapRecognizerCallback: tapRecognizerCallback,
			markerViewOverlay: mapFactory.markerViewOverlay
		)
	}

	func makeZoomControl() -> some View {
		MapControl(controlFactory: self.mapFactory.mapControlFactory.makeZoomControl)
	}

	func makeCustomControl() -> some View {
		MapControl(controlFactory: { [mapFactory = self.mapFactory] in
			CustomZoomControl(map: mapFactory.map)
		})
	}

	func makeCompassControl() -> some View {
		MapControl(
			controlFactory: self.mapFactory.mapControlFactory.makeCompassControl
		)
	}

	func makeCurrentLocationControl() -> some View {
		MapControl(
			controlFactory: self.mapFactory.mapControlFactory.makeCurrentLocationControl
		)
	}

	func makeIndoorControl() -> some View {
		return MapControl(controlFactory: { [mapFactory = self.mapFactory] in
			mapFactory.mapControlFactory.makeIndoorControl(
				IndoorControlOptions(
					visibilityBehavior: .automatic
				)
			)
		})
	}

	func makeSearchView(searchStore: SearchStore) -> some View {
		return SearchView(store: searchStore)
	}

	func makeCircleView(viewModel: CircleViewModel, show: Binding<Bool>) -> some View {
		return CircleView(viewModel: viewModel, show: show)
	}

	func makeMarkerView(viewModel: MarkerViewModel, show: Binding<Bool>) -> some View {
		return MarkerView(viewModel: viewModel, show: show)
	}

	func makePolygonView(viewModel: PolygonViewModel, show: Binding<Bool>) -> some View {
		return PolygonView(viewModel: viewModel, show: show)
	}

	func makePolylineView(viewModel: PolylineViewModel, show: Binding<Bool>) -> some View {
		return PolylineView(viewModel: viewModel, show: show)
	}

	func makeMapObjectCardView(_ viewModel: MapObjectCardViewModel) -> some View {
		return MapObjectCardView(viewModel: viewModel)
	}

	func makeClusterCardView(_ viewModel: ClusterCardViewModel) -> some View {
		return ClusterCardView(viewModel: viewModel)
	}
}
