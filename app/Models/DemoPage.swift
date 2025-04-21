enum DemoCategory: String, CaseIterable, Identifiable {
	case map, search, navigation

	var id: String {
		self.rawValue
	}

	var displayName: String {
		switch self {
		case .map:
			return "Map"
		case .search:
			return "Search"
		case .navigation:
			return "Navigation"
		}
	}
	
	var iconName: String {
		switch self {
		case .map:
			return "map"
		case .search:
			return "magnifyingglass"
		case .navigation:
			return "location.circle"
		}
	}
}

enum DemoFramework: String, CaseIterable, Identifiable {
	case uiKit, swiftUI
	
	var id: String {
		self.rawValue
	}
	
	var displayName: String {
		switch self {
		case .uiKit:
			return "UIKit"
		case .swiftUI:
			return "SwiftUI"
		}
	}
}

enum DemoPage: String, CaseIterable, Identifiable {
	case benchmark
	case cache
	case cameraCalcPosition
	case cameraMoves
	case cameraRestrictions
	case clustering
	case copyrightSettings
	case customGestures
	case customMapControls
	case directorySearch
	case fpsRestrictions
	case graphicsOptions
	case locale
	case mapControls
	case mapInteraction
	case mapObjects
	case mapSnapshot
	case mapTheme
	case mapViewMarkers
	case multiViewPorts
	case parkings
	case rasterTiles
	case roadEvents
	case staticMaps
	case trafficContol
	case visibleAreaDetection
	case visibleRectVisibleArea
	case minimap
	case navigator
	case packageManager
	case routeEditor

	var id: String {
		return self.rawValue
	}

	var name: String {
		switch self {
		case .benchmark:
			return "Benchmark"
		case .cache:
			return "Cache"
		case .cameraCalcPosition:
			return "Camera calcPosition"
		case .cameraRestrictions:
			return "Camera restrictions"
		case .cameraMoves:
			return "Camera moves"
		case .clustering:
			return "Clustering"
		case .copyrightSettings:
			return "Copyright settings"
		case .customGestures:
			return "Custom gestures"
		case .customMapControls:
			return "Custom map controls"
		case .directorySearch:
			return "Directory search"
		case .fpsRestrictions:
			return "FPS restrictions"
		case .graphicsOptions:
			return "Graphics options"
		case .locale:
			return "Change locale"
		case .mapControls:
			return "Map controls"
		case .mapInteraction:
			return "Map interaction"
		case .mapObjects:
			return "Map objects"
		case .mapSnapshot:
			return "Map snapshot"
		case .mapTheme:
			return "Map theme"
		case .mapViewMarkers:
			return "Map ViewMarkers"
		case .multiViewPorts:
			return "Multi ViewPorts"
		case .parkings:
			return "Parkings on map"
		case .rasterTiles:
			return "Raster tiles"
		case .roadEvents:
			return "Road events"
		case .staticMaps:
			return "Static maps"
		case .trafficContol:
			return "Traffic on map"
		case .visibleAreaDetection:
			return "Visible area detection"
		case .visibleRectVisibleArea:
			return "Visible rect/visible area"
		case .minimap:
			return "Minimap"
		case .navigator:
			return "Navigator"
		case .packageManager:
			return "Package manager"
		case .routeEditor:
			return "Route editor"
		}
	}

	var framework: [DemoFramework] {
		switch self {
		case .customMapControls:
			return [.swiftUI, .uiKit]
		case .mapControls:
			return [.swiftUI, .uiKit]
		case .mapInteraction:
			return [.swiftUI, .uiKit]
		case .mapViewMarkers:
			return [.swiftUI, .uiKit]
		case .roadEvents:
			return [.uiKit]
		case .navigator:
			return [.swiftUI, .uiKit]
		default: return [.swiftUI]
		}
	}

	var category: DemoCategory {
		switch self {
		case .directorySearch:
			return .search
		case .routeEditor:
			return .navigation
		case .minimap:
			return .navigation
		case .navigator:
			return .navigation
		default :
			return .map
		}
	}
}
