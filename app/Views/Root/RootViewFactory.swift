import SwiftUI
import PlatformSDK

struct RootViewFactory {
	private let sdk: PlatformSDK.Container
	private let locationManagerFactory: () -> LocationService?

	init(
		sdk: PlatformSDK.Container,
		locationManagerFactory: @escaping () -> LocationService?
	) {
		self.sdk = sdk
		self.locationManagerFactory = locationManagerFactory
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
			case .dictionarySearch:
				self.makeSearchStylesDemoPage()
			case .mapStyles:
				self.makeCustomStylesDemoPage()
			case .visibleAreaDetection:
				self.makeVisibleAreaDetectionDemoPage()
		}
	}

	private func makeCustomStylesDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = CustomMapStyleDemoViewModel(
			styleFactory: { [sdk = self.sdk] in
				sdk.makeStyleFactory()
			},
			map: mapFactory.map
		)
		return CustomMapStyleDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeSearchStylesDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = SearchDemoViewModel(
			searchManagerFactory: { [sdk = self.sdk] in
				SearchManager.createOnlineManager(context: sdk.context)
			},
			map: mapFactory.map
		)
		return SearchDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory))
	}

	private func makeCameraDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
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
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: self.makeMapFactory())
		)
	}

	private func makeMarkersDemoPage() -> some View {
		let viewModel = MarkersDemoViewModel()
		return MarkersDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: self.makeMapFactory())
		)
	}

	private func makeVisibleAreaDetectionDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = VisibleAreaDetectionDemoViewModel(map: mapFactory.map)
		return VisibleAreaDetectionDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeMapObjectsIdentificationDemoPage() -> some View {
		let mapFactory = self.makeMapFactory()
		let viewModel = MapObjectsIdentificationDemoViewModel(
			searchManagerFactory: { [sdk = self.sdk] in
				SearchManager.createOnlineManager(context: sdk.context)
			},
			imageFactory: { [sdk = self.sdk] in
				sdk.imageFactory
			},
			map: mapFactory.map
		)
		return MapObjectsIdentificationDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: mapFactory)
		)
	}

	private func makeCustomMapControlsDemoPage() -> some View {
		let viewModel = CustomMapControlsDemoViewModel()
		return CustomMapControlsDemoView(
			viewModel: viewModel,
			viewFactory: self.makeDemoPageComponentsFactory(mapFactory: self.makeMapFactory())
		)
	}

	private func makeDemoPageComponentsFactory(mapFactory: IMapFactory) -> DemoPageComponentsFactory {
		DemoPageComponentsFactory(
			sdk: self.sdk,
			mapFactory: mapFactory
		)
	}

	private func makeMapFactory() -> IMapFactory {
		self.sdk.makeMapFactory(options: .default)
	}
}
