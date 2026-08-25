import SwiftUI
import DGis

struct CalcPositionDemoView: View {
	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject private var viewModel: CalcPositionDemoViewModel
	@SwiftUI.State private var showInfo = false
	@SwiftUI.State private var showSettingsView = false
	@SwiftUI.State private var showMapObjectsMenu = false
	private let mapFactory: IMapFactory

	init(
		viewModel: CalcPositionDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack {
			self.mapFactory.mapView
				.copyrightAlignment(.bottomRight)
				.showsAPIVersion(false)
			PaddingRectView(padding: self.$viewModel.paddingRect, color: .red)
			if !self.showSettingsView {
				VStack(alignment: .trailing) {
					Spacer()
					HStack {
						self.calcPositionButton
						.frame(width: 55, height: 55)
						.fixedSize()
						.padding(20)
						Spacer()
					}
				}
			}
			if self.showSettingsView {
				CalcPositionSettingsView(
					isPresented: self.$showSettingsView,
					padding: self.$viewModel.paddingRect,
					tilt: self.$viewModel.tilt.value,
					bearing: self.$viewModel.bearing.value,
					calcPositionWay: self.$viewModel.calcPositionWay,
					onApplySettings: self.viewModel.applyCameraSettings
				)
			}
			if self.showInfo {
				CalcPositionInfoView(isPresented: self.$showInfo)
			}
		}
		.edgesIgnoringSafeArea(.all)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: self.backButton, trailing: self.infoButton)
		.alert(isPresented: self.$viewModel.isErrorAlertShown) {
			Alert(title: Text(self.viewModel.errorMessage ?? ""))
		}
	}

	private var backButton : some View {
		Button(
			action: {
				self.presentationMode.wrappedValue.dismiss()
			}) {
			HStack {
				Image(systemName: "chevron.backward")
				Text("Back")
			}
		}
	}

	private var infoButton : some View {
		Button(
			action: {
				self.showInfo.toggle()
			}) {
			Image(systemName: self.showInfo ? "xmark" : "info.circle")
		}
	}

	private var calcPositionButton: some View {
		Button(action: {
			self.showMapObjectsMenu = true
		}) {
			ZStack {
				RoundedRectangle(cornerRadius: 10)
				.foregroundColor(Color(UIColor.systemBackground))
				.frame(width: 55, height: 55)
				.shadow(radius: 5)
				Image(systemName: "camera.viewfinder")
				.font(.largeTitle)
				.imageScale(.large)
				.foregroundColor(.accentColor)
			}
		}
		.actionSheet(isPresented: self.$showMapObjectsMenu) {
			ActionSheet(
				title: Text("Select objects to calculate camera position"),
				buttons: CalcPositionMapObjects.allCases.map { option in
						.default(Text(option.displayName)) {
							self.viewModel.selectedObjects = option
							self.showSettingsView = true
						}
				} + [.cancel()]
			)
		}
	}
}
