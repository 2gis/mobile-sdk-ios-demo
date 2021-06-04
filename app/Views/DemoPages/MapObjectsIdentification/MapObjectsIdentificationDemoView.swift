import SwiftUI

struct MapObjectsIdentificationDemoView: View {
	@ObservedObject private var viewModel: MapObjectsIdentificationDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: MapObjectsIdentificationDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			self.viewFactory.makeMapViewWithZoomControl() { location in
				self.viewModel.tap(location)
			}
			if let cardViewModel = viewModel.selectedObjectCardViewModel {
				self.viewFactory.makeMapObjectCardView(cardViewModel)
					.transition(.move(edge: .bottom))
			}
		}
		.edgesIgnoringSafeArea(.all)
	}
}
