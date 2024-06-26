enum DemoPage: String, CaseIterable {
	case camera
	case visibleAreaDetection
	case mapObjectsIdentification
	case mapObjects
	case customMapControls
	case mapTheme
	case dictionarySearch
	case fps
	case clustering
	case customGestures
	case copyrightSettings
	case calcPosition
	case territoryManager
	case routeSearch
	case navigator

	var name: String {
		switch self {
			case .camera:
				return "Camera moves"
			case .customMapControls:
				return "Custom map control buttons"
			case .mapObjects:
				return "Adding map objects to the map"
			case .mapTheme:
				return "Switch map theme"
			case .mapObjectsIdentification:
				return "Map objects identification"
			case .dictionarySearch:
				return "Directory search"
			case .visibleAreaDetection:
				return "Visible area detection"
			case .fps:
				return "Change map fps"
			case .clustering:
				return "Clustering"
			case .customGestures:
				return "Custom map control gestures"
			case .copyrightSettings:
				return "Copyright"
			case .calcPosition:
				return "Camera CalcPosition"
			case .territoryManager:
				return "Download territories"
			case .routeSearch:
				return "Route editor"
			case .navigator:
				return "Navigator"
		}
	}
}

extension DemoPage: Identifiable {
	var id: String {
		return self.rawValue
	}
}
