import DGis
import SwiftUI

struct MapViewMarkersDemoView: View {
	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject private var viewModel: MapViewMarkersDemoViewModel

	private let mapFactory: IMapFactory
	private let mapViewsFactory: IMapViewsFactory

	init(
		viewModel: MapViewMarkersDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.mapViewsFactory = self.mapFactory.mapViewsFactory
	}

	var body: some View {
		ZStack {
			ZStack {
				self.mapFactory.mapView
					.showsAPIVersion(true)
					.objectTappedCallback(callback: .init(
						callback: { [viewModel = self.viewModel] objectInfo in
							Task { @MainActor [weak viewModel] in
								viewModel?.tap(objectInfo: objectInfo)
							}
						}
					))
				self.viewModel.markerOverlayView
			}
			.edgesIgnoringSafeArea(.all)
			HStack {
				VStack {
					Spacer()
					self.mapViewsFactory.makeIndoorView()
						.frame(width: 38, height: 119)
						.fixedSize()
					Spacer()
				}
				.padding(10)
				Spacer()
				VStack {
					Spacer()
					self.mapViewsFactory.makeZoomView()
						.frame(width: 48, height: 102)
						.fixedSize()
					Spacer()
					self.mapViewsFactory.makeCompassView()
						.frame(width: 48)
						.fixedSize()
						.padding(.bottom, -32)
					self.mapViewsFactory.makeCurrentLocationView()
						.frame(width: 48)
						.fixedSize()
				}
				.padding(10)
			}
		}
		.sheet(isPresented: self.$viewModel.showSettings) {
			AnchorSheetView(
				isPresented: self.$viewModel.showSettings,
				anchor: self.$viewModel.anchor,
				offsetX: self.$viewModel.offsetX,
				offsetY: self.$viewModel.offsetY
			)
		}
		.alert(isPresented: self.$viewModel.isErrorAlertShown) {
			Alert(title: Text(self.viewModel.errorMessage ?? ""))
		}
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: self.backButton, trailing: self.settingsButton)
	}

	private var backButton: some View {
		Button(
			action: { self.presentationMode.wrappedValue.dismiss() }
		) {
			HStack {
				Image(systemName: "chevron.backward")
				Text("Back")
			}
		}
	}

	private var settingsButton: some View {
		Button(
			action: { self.viewModel.showSettings.toggle() }
		) {
			Image(systemName: "gearshape.fill")
		}
	}
}
