import SwiftUI

struct RootView: View {
	@EnvironmentObject private var navigationService: NavigationService
	@ObservedObject private var viewModel: RootViewModel
	private let viewFactory: RootViewFactory

	init(
		viewModel: RootViewModel,
		viewFactory: RootViewFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		List(self.viewModel.demoPages) { page in
			DemoPageListRow(page: page, action: {
				self.navigationService.push(self.destinationView(for: page), animated: true)
			})
		}
		.navigationBarTitle("2GIS MobileSDK Examples", displayMode: .inline)
		.navigationBarHidden(false)
	}

	private func destinationView(for page: DemoPage) -> some View {
		self.viewFactory.makeDemoPageView(page)
		.navigationBarTitle(page.name)
		.environmentObject(self.navigationService)
	}
}
