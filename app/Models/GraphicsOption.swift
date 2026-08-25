import DGis

enum GraphicsOption: String, CaseIterable {
	case `default`, lite, normal, immersive

	var preset: GraphicsPreset? {
		switch self {
		case .default:
			return nil
		case .lite:
			return .lite
		case .normal:
			return .normal
		case .immersive:
			return .immersive
		@unknown default:
			assertionFailure("Unknown value for GraphicsOption")
		}
	}
}

extension GraphicsOption: PickerViewOption {
	var id: GraphicsOption {
		self
	}

	var name: String {
		switch self {
		case .default:
			return "Default"
		case .lite:
			return "Lite"
		case .normal:
			return "Normal"
		case .immersive:
			return "Immersive"
		@unknown default:
			assertionFailure("Unknown value for GraphicsOption")
		}
	}
}
