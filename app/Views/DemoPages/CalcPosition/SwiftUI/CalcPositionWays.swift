enum CalcPositionWays: String, CaseIterable, Identifiable {
	case cameraParams, clonedCameraParams, calcPositionParams

	var id: String {
		self.rawValue
	}

	var displayName: String {
		switch self {
		case .cameraParams: return "Camera params"
		case .clonedCameraParams: return "Cloned camera params"
		case .calcPositionParams: return "CalcPosition params"
		@unknown default: fatalError("Unknown type: \(self)")
		}
	}
}
