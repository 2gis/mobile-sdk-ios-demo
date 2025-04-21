import SwiftUI
import DGis

struct GraphicsOptionsDemoView: View {
	@ObservedObject private var viewModel: GraphicsOptionsDemoViewModel
	private let mapFactory: IMapFactory
	
	init(
		viewModel: GraphicsOptionsDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}
	
	var body: some View {
		ZStack(alignment: .bottomLeading) {
			self.mapFactory.mapViewOverlay
			.mapViewOverlayCopyrightAlignment(.bottomLeft)
			.edgesIgnoringSafeArea(.all)
			VStack {
				Picker("Graphics Preset", selection: $viewModel.selectedOption) {
					ForEach(GraphicsOption.allCases) { source in
						Text(source.name).tag(source)
					}
				}
				.pickerStyle(SegmentedPickerStyle())
				.padding()
				Text("Current recommended option is: \(self.viewModel.recommendedOption)")
			}
			.padding(.bottom, 30)
		}
	}
}
