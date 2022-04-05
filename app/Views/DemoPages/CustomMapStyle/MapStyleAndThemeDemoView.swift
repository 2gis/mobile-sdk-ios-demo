import SwiftUI

struct MapStyleAndThemeDemoView: View {
	@ObservedObject private var viewModel: MapStyleAndThemeDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: MapStyleAndThemeDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			self.viewFactory.makeMapView(
				with: [.zoom],
				appearance: self.viewModel.currentTheme.mapAppearance,
				alignment: .bottomLeft
			)
			self.settingsButton()
			.actionSheet(item: self.$viewModel.settingsPage) { page in
				switch page {
					case .root:
						return self.rootSettingsActionSheet()
					case .theme:
						return self.themeSettingsActionSheet()
				}
			}
		}
		.sheet(isPresented: self.$viewModel.showsStylePicker) {
			StylePickerView(fileURL: self.$viewModel.stylePickerViewModel.styleFileURL)
		}
		.edgesIgnoringSafeArea(.all)
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "list.bullet") {
			self.viewModel.settingsPage = .root
		}
		.padding(.bottom, 40)
		.padding(.trailing, 20)
	}

	private func rootSettingsActionSheet() -> ActionSheet {
		ActionSheet(
			title: Text("Настройки"),
			buttons: [
				.default(Text("Смена стиля"), action: {
					self.viewModel.showsStylePicker = true
				}),
				.default(Text("Смена темы"), action: {
					self.viewModel.settingsPage = .theme
				}),
				.cancel()
			]
		)
	}

	private func themeSettingsActionSheet() -> ActionSheet {
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
