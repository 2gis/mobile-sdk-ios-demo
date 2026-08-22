import SwiftUI
import DGis

struct SwiftUIControlsDemoView: View {
	@ObservedObject private var viewModel: MapControlsDemoViewModel
	private let mapFactory: IMapFactory
	private let mapViewsFactory: IMapViewsFactory

	init(
		viewModel: MapControlsDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.mapViewsFactory = self.mapFactory.mapViewsFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			ZStack {
				self.mapFactory.mapView
					.showsAPIVersion(true)
					.objectTappedCallback(callback: .init(
						callback: { [weak viewModel = self.viewModel] objectInfo in
							Task { @MainActor in
								viewModel?.tap(objectInfo: objectInfo)
							}
						}
					))
				.edgesIgnoringSafeArea(.all)
				HStack {
					VStack {
						Spacer()
						self.mapViewsFactory.makeIndoorView(showOverview: false)
						.frame(width: 38, height: 119)
						.fixedSize()
						Spacer()
					}
					.padding(10)
					Spacer()
					VStack {
						self.mapViewsFactory.makeTrafficView()
						.frame(width: 48)
						.fixedSize()
						Spacer()
						self.mapViewsFactory.makeZoomView()
						.frame(width: 48, height: 102)
						.fixedSize()
						Spacer()
						self.mapViewsFactory.makeCompassView()
						.frame(width: 48)
						.fixedSize()
						self.mapViewsFactory.makeCurrentLocationView(permissionCallback: {})
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
