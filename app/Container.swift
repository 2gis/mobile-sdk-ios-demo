import SwiftUI
import PlatformSDK

final class Container {

	private lazy var apiKeys: APIKeys = {
		guard let info = Bundle.main.infoDictionary,
			let dirKey = info["DGISDirectoryAPIKey"] as? String,
			let mapKey = info["DGISMapAPIKey"] as? String,
			let apiKeys = APIKeys(directory: dirKey, map: mapKey)
		else {
			fatalError("2GIS API keys are missing or invalid. Check Info.plist")
		}
		return apiKeys
	}()

	private lazy var sdk = PlatformSDK.Container(
		apiKeys: self.apiKeys,
		httpOptions: HTTPOptions(timeout: 5, cacheOptions: nil)
	)

	private lazy var mapFactory: IMapFactory = self.sdk.makeMapFactory(options: .default)

	private lazy var locationManager = LocationService()

	func makeRootView() -> some View {
		let viewModel = self.makeRootViewModel()
		let viewFactory = self.makeViewFactory(viewModel: viewModel)
		return RootView(viewModel: viewModel, viewFactory: viewFactory)
	}

	private func makeViewFactory(viewModel: RootViewModel) -> RootViewFactory {
		let viewFactory = RootViewFactory(
			viewModel: viewModel,
			markerViewModel: MarkerViewModel(
				imageFactory: self.sdk.imageFactory,
				map: self.mapFactory.map
			),
			routeViewModel: RouteViewModel(sourceFactory: { [sdk = self.sdk] in
					return sdk.sourceFactory
				},
				routeEditorSourceFactory: { [sdk = self.sdk] routeEditor in
					return sdk.sourceFactory.createRouteEditorSource(routeEditor: routeEditor)
				},
				routeEditorFactory: { [sdk = self.sdk] in
					return RouteEditor(context: sdk.context)
				},
				map: self.mapFactory.map
			),
			mapUIViewFactory: {
				[mapFactory = self.mapFactory] in
				mapFactory.mapView
			},
			customZoomControlFactory: {
				[mapFactory = self.mapFactory] in
				CustomZoomControl(map: mapFactory.map)
			},
			mapControlFactory: self.mapFactory.mapControlFactory
		)
		return viewFactory
	}

	private func makeRootViewModel() -> RootViewModel {
		let rootViewModel = RootViewModel(
			searchManagerFactory: { [sdk = self.sdk] in
				SearchManager.createOnlineManager(context: sdk.context)
			},
			sourceFactory: { [sdk = self.sdk] in
				sdk.sourceFactory
			},
			styleFactory: sdk.makeStyleFactory,
			imageFactory: { [sdk = self.sdk] in
				sdk.imageFactory
			},
			locationManagerFactory: { [weak self] in
				self?.locationManager
			},
			map: self.mapFactory.map
		)
		return rootViewModel
	}
}
