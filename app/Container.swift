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

	private lazy var locationManager = LocationService()

	func makeRootView() -> some View {
		let viewModel = self.makeRootViewModel()
		let viewFactory = self.makeRootViewFactory()
		return RootView(viewModel: viewModel, viewFactory: viewFactory)
	}

	private func makeRootViewFactory() -> RootViewFactory {
		let viewFactory = RootViewFactory(
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
			mapFactory: { [sdk = self.sdk] in
				sdk.makeMapFactory(options: .default)
			},
			routeEditorFactory: { [sdk = self.sdk] in
				return RouteEditor(context: sdk.context)
			},
			routeEditorSourceFactory: { [sdk = self.sdk] routeEditor in
				return RouteEditorSource(context: sdk.context, routeEditor: routeEditor)
			}
		)
		return viewFactory
	}

	private func makeRootViewModel() -> RootViewModel {
		let rootViewModel = RootViewModel(demoPages: DemoPage.allCases)
		return rootViewModel
	}
}
