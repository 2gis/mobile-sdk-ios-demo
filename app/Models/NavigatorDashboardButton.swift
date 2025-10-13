import Foundation

enum NavigatorDashboardButton: String, CaseIterable {
	case `default`, exitButton
}

extension NavigatorDashboardButton: PickerViewOption {
	var id: NavigatorDashboardButton {
		self
	}

	var name: String {
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
