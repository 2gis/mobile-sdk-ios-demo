import SwiftUI

struct CustomGesturesDemoView: View {
	@ObservedObject private var viewModel: CustomGesturesDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: CustomGesturesDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack {
			ZStack(alignment: .top) {
				self.viewFactory.makeMapViewWithZoomControl(
					mapGesturesType: self.viewModel.currentMapGesturesType
				)
				self.gestureTypePicker()
			}
		}
		.edgesIgnoringSafeArea([.leading, .bottom, .trailing])
	}

	private func gestureTypePicker() -> some View {
		HStack {
			Spacer()
			Picker("", selection: self.$viewModel.currentMapGesturesType) {
				ForEach(self.viewModel.mapGestureTypes) { type in
					Text(type.name)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			Spacer()
		}
		.padding(.top, 10)
	}
}
