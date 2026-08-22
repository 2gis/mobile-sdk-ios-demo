import DGis
import Foundation

enum NavigatorTheme: String, CaseIterable {
	case `default`, custom
}

extension NavigatorTheme: @MainActor PickerViewOption {
	nonisolated var id: NavigatorTheme {
		self
	}

	nonisolated var name: String {
		switch self {
		case .default:
			return "Default"
		case .custom:
			return "Custom"
		@unknown default:
			assertionFailure("Unknown value for NavigatorTheme")
		}
	}
}

extension NavigatorTheme {
	var navigationViewTheme: NavigationViewTheme {
		switch self {
		case .default:
			return NavigationViewTheme.default
		case .custom:
			return NavigationViewTheme.custom
		@unknown default:
			assertionFailure("Unknown value for NavigatorTheme")
			return .default
		}
	}
}
