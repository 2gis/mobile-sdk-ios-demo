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
        httpOptinos: HTTPOptions(timeout: 5, cacheOptions: nil)
    )

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
				map: self.sdk.map
			),
			routeViewModel: RouteViewModel(sourceFactory: { [sdk = self.sdk] in
					return sdk.sourceFactory
				},
				routeEditorSourceFactory: { [sdk = self.sdk] routeEditor in
					return createRouteEditorSource(context: sdk.context, routeEditor: routeEditor)
				},
				routeEditorFactory: { [sdk = self.sdk] in
					return RouteEditor(context: sdk.context)
				},
				map: self.sdk.map
			),
			mapUIViewFactory: {
				[sdk = self.sdk] in
				sdk.mapView
			},
			mapControlFactory: self.sdk.mapControlFactory
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
			imageFactory: { [sdk = self.sdk] in
				sdk.imageFactory
			},
			locationManagerFactory: { [weak self] in
				self?.locationManager
			},
			map: self.sdk.map
		)
		return rootViewModel
	}
}
