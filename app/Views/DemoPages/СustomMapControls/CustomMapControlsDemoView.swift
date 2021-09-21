import SwiftUI

struct CustomMapControlsDemoView: View {
	@ObservedObject private var viewModel: CustomMapControlsDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: CustomMapControlsDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack {
			ZStack(alignment: .top) {
				self.viewFactory.makeMapView()
				self.controlTypePicker()
			}
			self.zoomControls()
		}
		.edgesIgnoringSafeArea([.leading, .bottom, .trailing])
	}

	private func controlTypePicker() -> some View {
		HStack {
			Spacer()
			Picker("", selection: self.$viewModel.controlsType) {
				ForEach(self.viewModel.controlTypes) { type in
					Text(type.title)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			Spacer()
		}
		.padding(.top, 10)
	}

	@ViewBuilder
	private func zoomControls() -> some View {
		HStack {
			Spacer()
			switch self.viewModel.controlsType {
				case .default:
					self.viewFactory.makeZoomControl()
					.frame(width: 48, height: 104)
					.fixedSize()
					.padding(10)
				case .custom:
					self.viewFactory.makeCustomControl()
					.frame(width: 48, height: 104)
					.fixedSize()
					.padding(10)
			}
		}
	}
}
