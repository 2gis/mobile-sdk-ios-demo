import SwiftUI

struct MapThemeDemoView: View {
	@ObservedObject private var viewModel: MapThemeDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: MapThemeDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			self.viewFactory.makeMapView(appearance: self.viewModel.currentTheme.mapAppearance)
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
				ActionSheet.Button.default(Text(theme.title)) {
					self.viewModel.currentTheme = theme
				}
			}
			buttons.append(.cancel(Text("Отмена")))
			return ActionSheet(
				title: Text("Сменить тему"),
				message: Text("Текущая тема: \(self.viewModel.currentTheme.title)"),
				buttons: buttons
			)
		}
	}
}
