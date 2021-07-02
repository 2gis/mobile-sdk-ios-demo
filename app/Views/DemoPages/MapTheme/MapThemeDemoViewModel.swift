import SwiftUI
import Combine
import DGis

final class MapThemeDemoViewModel: ObservableObject {
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
	@Published var showActionSheet = false
	@Published var currentTheme: Theme = .default
	let availableThemes: [Theme] = Theme.allCases

	init() {}
}


