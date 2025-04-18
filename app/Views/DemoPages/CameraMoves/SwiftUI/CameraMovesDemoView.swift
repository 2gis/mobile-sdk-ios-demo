import SwiftUI
import DGis

struct CameraMovesDemoView: View {
	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject private var viewModel: CameraMovesDemoViewModel
	private let mapFactory: IMapFactory

	init(
		viewModel: CameraMovesDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			self.mapFactory.mapViewOverlay
				.mapViewOverlayCopyrightAlignment(.bottomLeft)
		}
		.edgesIgnoringSafeArea(.all)
		.actionSheet(isPresented: self.$viewModel.showActionSheet) { self.cameraMoveMenu }
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: self.backButton, trailing: self.menuButton)
	}

	private var cameraMoveMenu: ActionSheet {
		ActionSheet(
			title: Text("Test Flights"),
			buttons: [
				.default(Text("Moscow Flight")) {
					self.viewModel.testCamera()
				},
				.default(Text("Move to my position")) {
					self.viewModel.showCurrentPosition()
				},
				.cancel(Text("Cancel"))]
		)
	}

	private var backButton: some View {
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

	private var menuButton: some View {
		Button(action: {
			self.viewModel.showActionSheet = true
		}) {
			Image(systemName: "list.bullet")
		}
	}
}
