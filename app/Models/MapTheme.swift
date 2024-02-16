import Foundation
import DGis

enum MapTheme: String, CaseIterable {
	case `default`, dark, light, system

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

extension MapTheme: PickerViewOption {
	var id: MapTheme {
		self
	}

	var name: String {
		switch self {
			case .default:
				return "Default"
			case .dark:
				return "Dark"
			case .light:
				return "Light"
			case .system:
				return "System"
		}
	}
}
