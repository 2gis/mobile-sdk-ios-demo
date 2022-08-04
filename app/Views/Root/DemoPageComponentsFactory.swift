import SwiftUI
import DGis

struct DemoPageComponentsFactory {
	private let sdk: DGis.Container
	private let mapFactory: IMapFactory
	private let settingsService: ISettingsService

	internal init(
		sdk: DGis.Container,
		mapFactory: IMapFactory,
		settingsService: ISettingsService
	) {
		self.sdk = sdk
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

	func makeCurrentLocationControl() -> some View {
		MapControl(
			controlFactory: self.mapFactory.mapControlFactory.makeCurrentLocationControl
		)
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

	func makeRouteView(
		show: Binding<Bool>,
		transportType: TransportType,
		carRouteSearchOptions: CarRouteSearchOptions,
		publicTransportRouteSearchOptions: PublicTransportRouteSearchOptions,
		truckRouteSearchOptions: TruckRouteSearchOptions,
		taxiRouteSearchOptions: TaxiRouteSearchOptions,
		bicycleRouteSearchOptions: BicycleRouteSearchOptions,
		pedestrianRouteSearchOptions: PedestrianRouteSearchOptions
	) -> some View {
		let viewModel = RouteViewModel(
			transportType: transportType,
			carRouteSearchOptions: carRouteSearchOptions,
			publicTransportRouteSearchOptions: publicTransportRouteSearchOptions,
			truckRouteSearchOptions: truckRouteSearchOptions,
			taxiRouteSearchOptions: taxiRouteSearchOptions,
			bicycleRouteSearchOptions: bicycleRouteSearchOptions,
			pedestrianRouteSearchOptions: pedestrianRouteSearchOptions,
			sourceFactory: { [sdk = self.sdk] in
				sdk.sourceFactory
			},
			routeEditorSourceFactory: { [sdk = self.sdk] routeEditor in
				return RouteEditorSource(context: sdk.context, routeEditor: routeEditor)
			},
			routeEditorFactory: { [sdk = self.sdk] in
				return RouteEditor(context: sdk.context)
			},
			map: self.mapFactory.map,
			feedbackGenerator: FeedbackGenerator()
		)
		return RouteView(viewModel: viewModel, show: show, viewFactory: self)
	}

	func makeNavigatorView(
		navigationManager: NavigationManager,
		roadEventCardPresenter: IRoadEventCardPresenter,
		onCloseButtonTapped: (() -> Void)?,
		onMapTapped: ((CGPoint) -> Void)?,
		onMapLongPressed: ((CGPoint) -> Void)?
	) -> some View {
		var options = NavigationViewOptions.default
		if self.settingsService.navigatorTheme == .custom {
			options.theme = NavigationViewTheme.custom
		}
		return NavigatorView(
			mapFactory: self.mapFactory,
			navigationViewFactory: self.sdk.makeNavigationViewFactory(options: options),
			navigationManager: navigationManager,
			roadEventCardPresenter: roadEventCardPresenter,
			onCloseButtonTapped: onCloseButtonTapped,
			onMapTapped: onMapTapped,
			onMapLongPressed: onMapLongPressed
		)
	}

	func makeRoutePreviewListVC(routesInfo: RouteEditorRoutesInfo) -> RoutePreviewListVC {
		let factory = self.sdk.makeNavigationViewFactory()
		return RoutePreviewListVC(routesInfo: routesInfo, factory: factory)
	}

	func makeRouteDetailsVC(route: TrafficRoute) -> RouteDetailsVC {
		let factory = self.sdk.makeNavigationViewFactory()
		return RouteDetailsVC(route: route, factory: factory)
	}
}
