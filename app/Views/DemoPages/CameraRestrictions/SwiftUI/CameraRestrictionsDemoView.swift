import SwiftUI
import DGis

struct CameraRestrictionsDemoView: View {
	typealias State = SwiftUI.State
	
	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject private var viewModel: CameraRestrictionsDemoViewModel
	@State private var showingSettings = false
	private let mapFactory: IMapFactory
	private let mapControlViewFactory: IMapControlViewFactory

	init(
		viewModel: CameraRestrictionsDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.mapControlViewFactory = mapFactory.mapControlViewFactory
	}

	var body: some View {
		ZStack {
			ZStack(alignment: .center) {
				self.mapFactory.mapViewOverlay
				.mapViewOverlayShowsAPIVersion(true)
				.edgesIgnoringSafeArea(.all)
				HStack {
					Spacer()
					VStack {
						self.mapControlViewFactory.makeZoomView()
						.frame(width: 48, height: 102)
						.fixedSize()
						.padding(20)
						self.mapControlViewFactory.makeCompassView()
						.frame(width: 48, height: 48)
						.fixedSize()
						self.customCurrentLocationControl
						.frame(width: 48, height: 48)
						.fixedSize()
					}
				}
			}
			VStack {
				HStack {
					Text(self.viewModel.cameraPosition)
					.font(.footnote)
					.foregroundColor(.white)
					.padding(5)
					.background(Color.black.opacity(0.2))
					.cornerRadius(5)
					.padding()
					Spacer()
				}
				Spacer()
			}
			if self.showingSettings {
				CameraRestrictionsSettingsView(
					isPresented: self.$showingSettings,
					minZoom: self.$viewModel.minZoom,
					maxZoom: self.$viewModel.maxZoom,
					maxTiltRelationPoints: self.$viewModel.maxTiltRelationPoints,
					zoomToTiltRelationPoints: self.$viewModel.zoomToTiltRelationPoints,
					onApplySettings: self.viewModel.applySettings
				)
			}
		}
		.alert(isPresented: self.$viewModel.isErrorAlertShown) {
			Alert(title: Text(self.viewModel.errorMessage ?? ""))
		}
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: self.backButton, trailing: self.showingSettings ? nil : self.settingsButton)
	}

	private var backButton: some View {
		Button(
			action: {
				self.showingSettings ? self.showingSettings.toggle() : self.presentationMode.wrappedValue.dismiss()
			}) {
			HStack {
				Image(systemName: "chevron.backward")
				Text("Back")
			}
		}
	}

	private var settingsButton: some View {
		Button(
			action: {
				self.showingSettings.toggle()
			}) {
				Image(systemName: "gearshape.fill")
			}
	}

	private var customCurrentLocationControl: some View {
		self.mapControlViewFactory.makeCurrentLocationView()
			.simultaneousGesture(TapGesture().onEnded {
				self.viewModel.followControllerButtonClick()
			})
	}
}
