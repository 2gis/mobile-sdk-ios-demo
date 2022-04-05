import SwiftUI
import Combine
import DGis

final class MapStyleAndThemeDemoViewModel: ObservableObject {
	enum SettingsPage: Identifiable {
		case root
		case theme

		var id: SettingsPage { self }
	}

	enum Theme: CaseIterable {
		case `default`, dark, light, system

		var title: String {
			switch self {
				case .default:
					return "Тема стиля по умолчанию"
				case .dark:
					return "Темная"
				case .light:
					return "Светлая"
				case .system:
					return "Системная"
			}
		}

		var mapAppearance: MapAppearance {
			switch self {
				case .default:
					return .default
				case .dark:
					return .universal("night")
				case .light:
					return .universal("day")
				case .system:
					return .automatic(light: "day", dark: "night")
			}
		}
	}
	/// Whether a style picker sheet is to be displayed.
	@Published var showsStylePicker: Bool = false
	@Published var settingsPage: SettingsPage?
	@Published var currentTheme: Theme = .default
	let availableThemes: [Theme] = Theme.allCases
	var stylePickerViewModel: StylePickerViewModel

	private let map: Map
	private var loadStyleCancellable: DGis.Cancellable?

	init(
		styleFactory: @escaping () -> IStyleFactory,
		map: Map
	) {
		self.map = map
		self.stylePickerViewModel = StylePickerViewModel(
			styleFactory: styleFactory,
			map: self.map
		)
	}

	func showSettings() {
		self.settingsPage = .root
	}

	func showThemeSettings() {
		self.settingsPage = .theme
	}

	func selectStyle() {
		self.showsStylePicker = true
	}
}
