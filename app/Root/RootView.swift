import SwiftUI
import PlatformSDK

struct RootView: View {
	private let viewModel: RootViewModel
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
			ZStack(alignment: .bottomTrailing) {
				self.viewFactory.makeMapView()
				self.mapTestButton()
			}
			.navigationBarItems(
				leading: self.navigationBarLeadingItem()
			)
			.navigationBarTitle("2GIS", displayMode: .inline)
			.edgesIgnoringSafeArea(.all)
		}.navigationViewStyle(StackNavigationViewStyle())
	}

	private func navigationBarLeadingItem() -> some View {
		NavigationLink(destination: self.viewFactory.makeSearchView()) {
			Image(systemName: "magnifyingglass.circle.fill")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(minWidth: 32, minHeight: 32)
		}
	}

	private func mapTestButton() -> some View {
		Button(action: {
			self.viewModel.testCamera()
		}) {
			Image(systemName: "mappin.and.ellipse")
				.background(Image(systemName: "circle").scaleEffect(2))
				.padding([.bottom, .trailing], 40)
				.contentShape(Rectangle().scale(2))
		}
	}
}
