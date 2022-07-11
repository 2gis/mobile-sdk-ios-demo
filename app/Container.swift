import SwiftUI
import DGis

final class Container {
	private lazy var sdk = DGis.Container(
		apiKeyOptions: .default,
		httpOptions: HTTPOptions(timeout: 5, cacheOptions: nil)
	)

	private lazy var locationManager = LocationService()

	private lazy var navigationService: NavigationService = NavigationService()

	func makeRootView() -> some View {
		let viewModel = self.makeRootViewModel()
		let viewFactory = self.makeRootViewFactory()
		return RootView(
			viewModel: viewModel,
			viewFactory: viewFactory
		)
		.environmentObject(self.navigationService)
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
