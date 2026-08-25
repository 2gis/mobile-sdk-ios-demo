import Foundation

enum NavigatorDashboardButton: String, CaseIterable {
	case `default`, exitButton
}

extension NavigatorDashboardButton: @MainActor PickerViewOption {
	nonisolated var id: NavigatorDashboardButton {
		self
	}

	nonisolated var name: String {
		switch self {
		case .default:
			return "Default"
		case .exitButton:
			return "Exit button"
		@unknown default:
			assertionFailure("Unknown value for NavigatorDashboardButton")
		}
	}
}
