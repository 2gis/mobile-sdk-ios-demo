import SwiftUI

struct CameraDemoView: View {
	@ObservedObject private var viewModel: CameraDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: CameraDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			self.viewFactory.makeMapViewWithZoomControl(alignment: .bottomLeft)
			self.settingsButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
		}
		.edgesIgnoringSafeArea(.all)
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "list.bullet") {
			self.viewModel.showActionSheet = true
		}
		.padding(.bottom, 40)
		.padding(.trailing, 20)
		.actionSheet(isPresented: self.$viewModel.showActionSheet) {
			ActionSheet(
				title: Text("Test movings"),
				buttons: [
					.default(Text("Move camera around Moscow")) {
						self.viewModel.testCamera()
					},
					.default(Text("Move camera to current position")) {
						self.viewModel.showCurrentPosition()
					},
					.cancel(Text("Отмена"))
				])
		}
	}
}
