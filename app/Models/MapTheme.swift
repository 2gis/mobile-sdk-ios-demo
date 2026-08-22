import DGis
import Foundation

enum MapTheme: String, CaseIterable {
	case `default`, dark, light, system

	var mapAppearance: MapAppearance {
		switch self {
		case .default:
			return .fixed(.init(theme: .defaultTheme))
		case .dark:
			return .fixed(.init(theme: .defaultDarkTheme))
		case .light:
			return .fixed(.init(theme: .defaultTheme))
		case .system:
			return .bySystem(.init(light: .defaultTheme, dark: .defaultDarkTheme))
		@unknown default:
			assertionFailure("Unknown value for MapTheme")
		}
	}
}

extension MapTheme: @MainActor PickerViewOption {
	nonisolated var id: MapTheme {
		self
	}

	nonisolated var name: String {
		switch self {
		case .default:
			return "Default"
		case .dark:
			return "Dark"
		case .light:
			return "Light"
		case .system:
			return "System"
		@unknown default:
			assertionFailure("Unknown value for MapTheme")
		}
	}
}
