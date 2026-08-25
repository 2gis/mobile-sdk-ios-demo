import DGis
import SwiftUI

enum ActionPoint: String, CaseIterable, Identifiable {
	case eventCenter, mapPosition, targetGeoPoint

	public var id: ActionPoint {
		self
	}

	var title: String {
		switch self {
		case .eventCenter: return "EventCenter"
		case .mapPosition: return "MapPosition"
		case .targetGeoPoint: return "TargetGeoPoint"
		@unknown default: fatalError("Unknown type: \(self)")
		}
	}
}

extension ActionPoint {
	init(from gestureActionPoint: GestureActionPoint) {
		switch gestureActionPoint {
		case .eventCenter:
			self = .eventCenter
		case .mapPosition:
			self = .mapPosition
		case .targetGeoPoint:
			self = .targetGeoPoint
		@unknown default:
			fatalError("Unknown type ActionPoint")
		}
	}

	func makeGestureActionPoint(targetGeoPoint: GeoPointWithElevation?) -> GestureActionPoint {
		switch self {
		case .eventCenter: return .eventCenter(.init())
		case .mapPosition: return .mapPosition(.init())
		case .targetGeoPoint: return targetGeoPoint.map { .targetGeoPoint(.init(targetGeoPoint: $0.point)) } ?? .eventCenter(.init())
		@unknown default: fatalError("Unknown type: \(self)")
		}
	}
}

enum MapGestureType: UInt {
	case mapRecognizer
	case platform
	case custom

	mutating func next() {
		self = MapGestureType(rawValue: self.rawValue + 1) ?? .mapRecognizer
	}

	var text: String {
		switch self {
		case .mapRecognizer: return "MapRecognizer"
		case .platform: return "Platform"
		case .custom: return "Custom"
		@unknown default: fatalError("Unknown type: \(self)")
		}
	}

	func makeMapGestureUIViewFactory(options: MapGestureViewOptions) -> IMapGestureUIViewFactory {
		switch self {
		case .mapRecognizer: return MapGestureRecognizerUIViewFactory(pinchScalingCenter: options.pinchScalingCenter)
		case .platform: return MapGestureUIViewFactory(options: options)
		case .custom: return CustomGestureViewFactory()
		@unknown default: fatalError("Unknown type: \(self)")
		}
	}
}
