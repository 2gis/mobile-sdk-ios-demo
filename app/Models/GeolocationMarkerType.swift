import DGis

enum GeolocationMarkerType: String, CaseIterable {
	case model, svgIcon

	var markerType: MyLocationMapObjectMarkerType {
		switch self {
		case .model:
			return .model
		case .svgIcon:
			return .svgIcon
		}
	}
}

extension GeolocationMarkerType: PickerViewOption {
	var id: GeolocationMarkerType {
		self
	}

	var name: String {
		switch self {
			case .model:
				return "3D Model"
			case .svgIcon:
				return "2D Icon"
		}
	}
}
