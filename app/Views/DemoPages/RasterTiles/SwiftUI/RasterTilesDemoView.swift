import SwiftUI
import DGis

struct RasterTilesDemoView: View {
	@ObservedObject private var viewModel: RasterTilesDemoViewModel
	private let mapFactory: IMapFactory

	init(
		viewModel: RasterTilesDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			ZStack(alignment: .trailing) {
				self.mapFactory.mapViewOverlay
				.mapViewOverlayCopyrightAlignment(.bottomLeft)
				.edgesIgnoringSafeArea(.all)
				VStack {
					Spacer()
					self.mapFactory.mapControlViewFactory.makeZoomView()
					Spacer()
				}
			}
			.edgesIgnoringSafeArea(.all)
			VStack {
				Picker("Tile Source", selection: $viewModel.selectedSource) {
					ForEach(TileSource.allCases) { source in
						Text(source.rawValue).tag(source)
					}
				}
				.pickerStyle(SegmentedPickerStyle())
				.padding()
				Slider(
					value: self.$viewModel.opacity,
					in: 0...1,
					step: 0.01
				)
				.padding()
				Spacer()
			}
		}
	}
}
