import DGis

enum GeolocationMarkerType: String, CaseIterable {
	case model, svgIcon

	var markerType: MyLocationMapObjectMarkerType {
		switch self {
		case .model:
			return .model
		case .svgIcon:
			return .svgIcon
		@unknown default:
			assertionFailure("Unknown value for GeolocationMarkerType")
		}
	}
}

extension GeolocationMarkerType: @MainActor PickerViewOption {
	nonisolated var id: GeolocationMarkerType {
		self
	}

	nonisolated var name: String {
		switch self {
		case .model:
			return "3D Model"
		case .svgIcon:
			return "2D Icon"
		@unknown default:
			assertionFailure("Unknown value for GeolocationMarkerType")
		}
	}
}
