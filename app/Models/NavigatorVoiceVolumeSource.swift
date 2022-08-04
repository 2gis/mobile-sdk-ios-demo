import Foundation

enum NavigatorVoiceVolumeSource: String, CaseIterable {
	case high, middle, low
}

extension NavigatorVoiceVolumeSource: PickerViewOption {
	var id: NavigatorVoiceVolumeSource {
		self
	}

	var name: String {
		switch self {
			case .high:
				return "High"
			case .middle:
				return "Medium"
			case .low:
				return "Low"
		}
	}
}
