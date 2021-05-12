import SwiftUI
import PlatformSDK

struct RootViewFactory {
	private let searchManagerFactory: () -> SearchManager
	private let sourceFactory: () -> ISourceFactory
	private let styleFactory: () -> IStyleFactory
	private let imageFactory: () -> IImageFactory
	private let locationManagerFactory: () -> LocationService?
	private let mapFactory: () -> IMapFactory
	private let routeEditorFactory: () -> RouteEditor
	private let routeEditorSourceFactory: (RouteEditor) -> RouteEditorSource

	init(
		searchManagerFactory: @escaping () -> SearchManager,
		sourceFactory: @escaping () -> ISourceFactory,
		styleFactory: @escaping () -> IStyleFactory,
		imageFactory: @escaping () -> IImageFactory,
		locationManagerFactory: @escaping () -> LocationService?,
		mapFactory: @escaping () -> IMapFactory,
		routeEditorFactory: @escaping () -> RouteEditor,
		routeEditorSourceFactory: @escaping (RouteEditor) -> RouteEditorSource
	) {
		self.searchManagerFactory = searchManagerFactory
		self.sourceFactory = sourceFactory
		self.styleFactory = styleFactory
		self.imageFactory = imageFactory
		self.locationManagerFactory = locationManagerFactory
		self.mapFactory = mapFactory
		self.routeEditorFactory = routeEditorFactory
		self.routeEditorSourceFactory = routeEditorSourceFactory
	}

	@ViewBuilder
	func makeDemoPageView(_ page: DemoPage) -> some View {
		switch page {
			case .camera:
				self.makeCameraDemoPage()
			case .customMapControls:
				self.makeCustomMapControlsDemoPage()
			case .routeSearch:
				self.makeRouteSearchDemoPage()
			case .mapObjectsIdentification:
				self.makeMapObjectsIdentificationDemoPage()
			case .markers:
				self.makeMarkersDemoPage()
			case .search:
				self.makeSearchStylesDemoPage()
			case .mapStyles:
				self.makeCustomStylesDemoPage()
			case .visibleAreaDetection:
				self.makeVisibleAreaDetectionDemoPage()
		}
	}

	private func makeCustomStylesDemoPage() -> some View {
		let mapFactory = self.mapFactory()
		let viewModel = CustomMapStyleDemoViewModel(
			styleFactory: self.styleFactory,
			map: mapFactory.map
		)
		return CustomMapStyleDemoView(viewModel: viewModel, viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory))
	}

	private func makeSearchStylesDemoPage() -> some View {
		let viewModel = SearchDemoViewModel(
			searchManagerFactory: self.searchManagerFactory
		)
		return SearchDemoView(viewModel: viewModel, viewFactory: self.makeDemoPageComponentsFactory(mapFactory: self.mapFactory()))
	}

	private func makeCameraDemoPage() -> some View {
		let mapFactory = self.mapFactory()
		let viewModel = CameraDemoViewModel(
			locationManagerFactory: self.locationManagerFactory,
			map: mapFactory.map
		)
		return CameraDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeRouteSearchDemoPage() -> some View {
		let viewModel = RouteSearchDemoViewModel()
		return RouteSearchDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: self.mapFactory())
		)
	}

	private func makeMarkersDemoPage() -> some View {
		let viewModel = MarkersDemoViewModel()
		return MarkersDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: self.mapFactory())
		)
	}

	private func makeVisibleAreaDetectionDemoPage() -> some View {
		let mapFactory = self.mapFactory()
		let viewModel = VisibleAreaDetectionDemoViewModel(map: mapFactory.map)
		return VisibleAreaDetectionDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeMapObjectsIdentificationDemoPage() -> some View {
		let mapFactory = self.mapFactory()
		let viewModel = MapObjectsIdentificationDemoViewModel(
			searchManagerFactory: searchManagerFactory,
			imageFactory: imageFactory,
			map: mapFactory.map
		)
		return MapObjectsIdentificationDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeCustomMapControlsDemoPage() -> some View {
		let mapFactory = self.mapFactory()
		let viewModel = CustomMapControlsDemoViewModel()
		return CustomMapControlsDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeDemoPageComponentsFactory(mapFactory: IMapFactory) -> DemoPageComponentsFactory {
		DemoPageComponentsFactory(
			mapFactory: mapFactory,
			imageFactory: self.imageFactory,
			sourceFactory: self.sourceFactory,
			routeEditorFactory: self.routeEditorFactory,
			routeEditorSourceFactory: self.routeEditorSourceFactory
		)
	}
}
