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
		Button(action: {
			self.viewModel.showsStylePicker = true
		}, label: {
			Image(systemName: "list.bullet")
				.frame(width: 40, height: 40, alignment: .center)
				.contentShape(Rectangle())
				.background(
					Circle().fill(Color.white)
				)
		})
		.padding(.bottom, 40)
		.padding(.trailing, 20)
	}
}
