import SwiftUI

struct SearchDemoView: View {
	@ObservedObject private var viewModel: SearchDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: SearchDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		self.viewFactory.makeMapView(with: [.zoom, .currentLocation], alignment: .bottomLeft)
		.navigationBarItems(
			trailing: self.navigationBarTrailingItem()
		)
		.edgesIgnoringSafeArea(.all)
	}

	private func navigationBarTrailingItem() -> some View {
		NavigationLink(destination: self.viewFactory.makeSearchView(searchStore: self.viewModel.searchStore)) {
			Image(systemName: "magnifyingglass.circle.fill")
			.resizable()
			.frame(minWidth: 32, minHeight: 32)
		}
	}
}
