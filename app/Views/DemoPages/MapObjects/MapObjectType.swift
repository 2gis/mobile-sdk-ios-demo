import SwiftUI
import DGis

enum MapObjectColor: UInt {
	case transparent
	case black
	case white
	case red
	case green
	case blue

	mutating func next() {
		self = MapObjectColor(rawValue: self.rawValue + 1) ?? .transparent
	}

	var text: String {
		switch self {
			case .transparent: return "Transparent"
			case .black: return "Black"
			case .white: return "White"
			case .red: return "Red"
			case .green: return "Green"
			case .blue: return "Blue"
		}
	}

	var value: DGis.Color {
		switch self {
			case .transparent: return .init()
			case .black: return .init(UIColor.black)!
			case .white: return .init(UIColor.white)!
			case .red: return .init(UIColor.red)!
			case .green: return .init(UIColor.green)!
			case .blue: return .init(UIColor.blue)!
		}
	}
}

enum StrokeWidth: UInt {
	case thin
	case medium
	case thick

	mutating func next() {
		self = StrokeWidth(rawValue: self.rawValue + 1) ?? .thin
	}

	var text: String {
		switch self {
			case .thin: return "Thin"
			case .medium: return "Medium"
			case .thick: return "Thick"
		}
	}

	var pixel: DGis.LogicalPixel {
		switch self {
			case .thin: return .init(value: 1)
			case .medium: return .init(value: 3)
			case .thick: return .init(value: 5)
		}
	}
}

enum MapObjectType: UInt {
	case circle
	case marker
	case polygon
	case polyline

	mutating func next() {
		self = MapObjectType(rawValue: self.rawValue + 1) ?? .circle
	}

	var text: String {
		switch self {
			case .circle: return "Circle"
			case .marker: return "Marker"
			case .polygon: return "Polygon"
			case .polyline: return "Polyline"
		}
	}
}
