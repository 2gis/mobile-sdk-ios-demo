import DGis
import SwiftUI

struct CustomMapViewsDemoView: View {
	@ObservedObject private var viewModel: CustomMapControlsDemoViewModel
	private let mapFactory: IMapFactory

	init(
		viewModel: CustomMapControlsDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack(alignment: .top) {
			self.mapFactory.mapViewOverlay
				.edgesIgnoringSafeArea(.all)
			Picker("", selection: self.$viewModel.controlsType) {
				ForEach(self.viewModel.controlTypes) { type in
					Text(type.title)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			VStack {
				Spacer()
				self.zoomControls()
					.padding()
				Spacer()
			}
			.frame(maxWidth: .infinity, alignment: .trailing)
		}
	}

	@ViewBuilder
	private func zoomControls() -> some View {
		switch self.viewModel.controlsType {
		case .default:
			self.mapFactory.mapControlViewFactory.makeZoomView()
				.fixedSize()
		case .custom:
			CustomZoomView(map: self.mapFactory.map)
				.fixedSize()
		}
	}
}
