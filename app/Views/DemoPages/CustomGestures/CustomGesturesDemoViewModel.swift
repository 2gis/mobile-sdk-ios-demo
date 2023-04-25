import SwiftUI
import Combine
import DGis

final class CustomGesturesDemoViewModel: ObservableObject {

	let mapGestureTypes = MapGesturesType.allCases
	@Published var currentMapGesturesType: MapGesturesType

	init(mapGesturesType: MapGesturesType) {
		self.currentMapGesturesType = mapGesturesType
	}

	func select(_ mapGesturesType: MapGesturesType) {
		self.currentMapGesturesType = mapGesturesType
	}
}

extension MapGesturesType {
	var name: String {
		switch self {
			case .default:
				return "Event"
			case .custom:
				return "Custom"
		}
	}
}
