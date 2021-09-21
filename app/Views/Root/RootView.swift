import SwiftUI

struct RootView: View {
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
		NavigationView  {
			List(self.viewModel.demoPages) { page in
				NavigationLink(
					destination: {
						LazyView(self.viewFactory.makeDemoPageView(page))
						.navigationBarTitle(page.name)
					}(),
					label: {
						DemoPageListRow(page: page)
					}
				)
			}
			.navigationBarTitle("2GIS MobileSDK Examples", displayMode: .inline)
		}
	}
}
