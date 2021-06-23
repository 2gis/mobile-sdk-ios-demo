import SwiftUI
import PlatformMapSDK

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

	private lazy var sdk = PlatformMapSDK.Container(
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
			sdk: self.sdk,
			locationManagerFactory: { [weak self] in
				self?.locationManager
			}
		)
		return viewFactory
	}

	private func makeRootViewModel() -> RootViewModel {
		let rootViewModel = RootViewModel(demoPages: DemoPage.allCases)
		return rootViewModel
	}
}
