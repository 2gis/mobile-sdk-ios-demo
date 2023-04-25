import Foundation

// Тема навигатора
enum NavigatorTheme: String, CaseIterable {
	case `default`, custom
}

extension NavigatorTheme: PickerViewOption {
	var id: NavigatorTheme {
		self
	}

	var name: String {
		switch self {
			case .default:
				return "System"
			case .custom:
				return "Custom"
		}
	}
}
