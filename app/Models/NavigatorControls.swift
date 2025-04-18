import Foundation

// Map navigator controls.
enum NavigatorControls: String, CaseIterable {
	case `default`, customControls
}

extension NavigatorControls: PickerViewOption {
	var id: NavigatorControls {
		self
	}

	var name: String {
		switch self {
			case .default:
				return "Default"
			case .customControls:
				return "Custom"
		}
	}
}
