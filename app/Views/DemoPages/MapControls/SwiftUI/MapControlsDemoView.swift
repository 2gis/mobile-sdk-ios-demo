import SwiftUI
import DGis

struct SwiftUIControlsDemoView: View {
	@ObservedObject private var viewModel: MapControlsDemoViewModel
	private let mapFactory: IMapFactory
	private let mapControlViewFactory: IMapControlViewFactory

	init(
		viewModel: MapControlsDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.mapControlViewFactory = self.mapFactory.mapControlViewFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			ZStack {
				self.mapFactory.mapViewOverlay
				.mapViewOverlayShowsAPIVersion(true)
				.mapViewOverlayObjectTappedCallback(callback: .init(
					callback: { [viewModel = self.viewModel] objectInfo in
						viewModel.tap(objectInfo: objectInfo)
					}
				))
				.edgesIgnoringSafeArea(.all)
				HStack {
					VStack {
						Spacer()
						self.mapControlViewFactory.makeIndoorView()
						.frame(width: 38, height: 119)
						.fixedSize()
						Spacer()
					}
					.padding(10)
					Spacer()
					VStack {
						self.mapControlViewFactory.makeTrafficView(colors: .default)
						.frame(width: 48)
						.fixedSize()
						Spacer()
						self.mapControlViewFactory.makeZoomView()
						.frame(width: 48, height: 102)
						.fixedSize()
						Spacer()
						self.mapControlViewFactory.makeCompassView()
						.frame(width: 48)
						.fixedSize()
						self.mapControlViewFactory.makeCurrentLocationView()
						.frame(width: 48)
						.fixedSize()
					}
					.padding(10)
				}
			}
			if let selectedMapObject = self.viewModel.selectedMapObject {
				MapObjectCardView(viewModel: selectedMapObject)
				.transition(.move(edge: .bottom))
			}
		}
		.alert(isPresented: self.$viewModel.isErrorAlertShown) {
			Alert(title: Text(self.viewModel.errorMessage ?? ""))
		}
	}
}
