import SwiftUI
import DGis

struct MapThemeDemoView: View {
	@ObservedObject private var viewModel: MapThemeDemoViewModel
	private let mapFactory: IMapFactory

	init(
		viewModel: MapThemeDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			self.mapFactory.mapView
				.appearance(self.viewModel.currentTheme.mapAppearance)
				.copyrightAlignment(.bottomLeft)
			self.settingsButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
		}
		.edgesIgnoringSafeArea(.all)
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "list.bullet") {
			self.viewModel.showActionSheet = true
		}
		.padding(.bottom, 40)
		.padding(.trailing, 20)
		.actionSheet(isPresented: self.$viewModel.showActionSheet) {
			var buttons = self.viewModel.availableThemes.map { theme in
				ActionSheet.Button.default(Text(theme.name)) {
					self.viewModel.currentTheme = theme
				}
			}
			buttons.append(.cancel(Text("Cancel")))
			return ActionSheet(
				title: Text("Change map theme"),
				message: Text("Current theme: \(self.viewModel.currentTheme.name)"),
				buttons: buttons
			)
		}
	}
}
