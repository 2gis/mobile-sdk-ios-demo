import Foundation

// Map navigator controls.
enum NavigatorControls: String, CaseIterable {
	case `default`, customControls
}

extension NavigatorControls: @MainActor PickerViewOption {
	nonisolated var id: NavigatorControls {
		self
	}

	nonisolated var name: String {
		switch self {
		case .default:
			return "Default"
		case .customControls:
			return "Custom"
		@unknown default:
			assertionFailure("Unknown value for NavigatorControls")
		}
	}
}
