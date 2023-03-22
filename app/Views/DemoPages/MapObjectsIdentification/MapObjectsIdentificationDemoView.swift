import SwiftUI
import DGis

struct MapObjectsIdentificationDemoView: View {
	@ObservedObject private var viewModel: MapObjectsIdentificationDemoViewModel
	private let viewFactory: DemoPageComponentsFactory
	private var mapView: MapView? = nil

	init(
		viewModel: MapObjectsIdentificationDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
		self.mapView = self.viewFactory.makeMapViewWithMarkerViewOverlay(tapRecognizerCallback: { [viewModel = self.viewModel] objectInfo in
			viewModel.tap(objectInfo: objectInfo)
		})
		self.viewModel.mapMarkerPresenter.setAddMarkerViewCallback { [mapView = self.mapView] markerView in
			mapView?.append(markerView: markerView)
		}
		self.viewModel.mapMarkerPresenter.setRemoveMarkerViewCallback { [mapView = self.mapView] markerView in
			mapView?.remove(markerView: markerView)
		}
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			ZStack(alignment: .center) {
				self.mapView
				HStack {
					Spacer()
					VStack {
						self.viewFactory.makeZoomControl()
						.frame(width: 48, height: 102)
						.fixedSize()
						.padding(20)
						self.viewFactory.makeCurrentLocationControl()
						.frame(width: 48, height: 48)
						.fixedSize()
					}
				}
			}
			if let selectedMapObject = self.viewModel.selectedMapObject {
				self.viewFactory.makeMapObjectCardView(selectedMapObject)
				.transition(.move(edge: .bottom))
			}
		}
		.edgesIgnoringSafeArea(.all)
	}
}
