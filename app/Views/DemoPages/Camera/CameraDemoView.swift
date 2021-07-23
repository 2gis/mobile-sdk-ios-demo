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
			self.viewFactory.makeMapView(with: [.zoom, .currentLocation], alignment: .bottomLeft)
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
				title: Text("Тестовые перелеты"),
				buttons: [
					.default(Text("Перелет по Москве")) {
						self.viewModel.testCamera()
					},
					.default(Text("Перелет в текущую геопозицию")) {
						self.viewModel.showCurrentPosition()
					},
					.cancel(Text("Отмена"))
				])
		}
	}
}
