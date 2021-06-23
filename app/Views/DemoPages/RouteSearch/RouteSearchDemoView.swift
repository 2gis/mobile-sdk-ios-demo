import SwiftUI

struct RouteSearchDemoView: View {
	@ObservedObject private var viewModel: RouteSearchDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: RouteSearchDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack {
			ZStack(alignment: .bottomTrailing) {
				self.viewFactory.makeMapViewWithZoomControl(alignment: .bottomLeft)
				if self.viewModel.showRoutes {
//					viewFactory.makeRouteView(show: $viewModel.showRoutes)
				} else {
					self.settingsButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
				}
			}
			if self.viewModel.showRoutes {
				Image(systemName: "multiply").frame(width: 40, height: 40, alignment: .center).foregroundColor(.red).opacity(0.4)
			}
		}
		.edgesIgnoringSafeArea(.all)
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "car.fill") {
			self.viewModel.showRoutes = true
		}
		.padding(.bottom, 40)
		.padding(.trailing, 20)
	}
}
