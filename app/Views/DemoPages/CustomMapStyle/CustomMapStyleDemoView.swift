import SwiftUI

struct CustomMapStyleDemoView: View {
	@ObservedObject private var viewModel: CustomMapStyleDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: CustomMapStyleDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			self.viewFactory.makeMapViewWithZoomControl(alignment: .bottomLeft)
			self.settingsButton()
		}
		.sheet(isPresented: self.$viewModel.showsStylePicker) {
			StylePickerView(fileURL: self.$viewModel.stylePickerViewModel.styleFileURL)
		}
		.edgesIgnoringSafeArea(.all)
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "list.bullet") {
			self.viewModel.showsStylePicker = true
		}
		.padding(.bottom, 40)
		.padding(.trailing, 20)
	}
}
