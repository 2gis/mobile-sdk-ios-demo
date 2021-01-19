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

	private lazy var sdk = PlatformSDK.Container(apiKeys: self.apiKeys)

	private lazy var locationManager = LocationService()

	func makeRootView() -> some View {
		let viewModel = self.makeRootViewModel()
		let viewFactory = self.makeViewFactory(viewModel: viewModel)
		return RootView(viewModel: viewModel, viewFactory: viewFactory)
	}

	private func makeViewFactory(viewModel: RootViewModel) -> RootViewFactory {
		let viewFactory = RootViewFactory(
			viewModel: viewModel,
			mapUIViewFactory: {
				[sdk = self.sdk] in
				sdk.mapView
			}
		)
		return viewFactory
	}

	private func makeRootViewModel() -> RootViewModel {
		let rootViewModel = RootViewModel(
			searchManagerFactory: { [sdk = self.sdk] in
				sdk.searchManagerFactory.makeOnlineManager()!
			},
			locationManagerFactory: { [weak self] in
				guard let self = self else { return nil }
				return self.locationManager
			},
			map: self.sdk.map
		)
		return rootViewModel
	}
}
