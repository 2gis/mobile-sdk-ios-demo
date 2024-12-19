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
			case .transparent: return .init(UIColor.clear)!
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

enum PolylineFillType: UInt {
	case solid
	case dashed
	case gradient
	
	mutating func next() {
		self = PolylineFillType(rawValue: self.rawValue + 1) ?? .solid
	}
	
	var text: String {
		switch self {
			case .solid: return "Solid"
			case .dashed: return "Dashed"
			case .gradient: return "Gradient"
		}
	}
	
	var dashedOptions: DashedPolylineOptions? {
		switch self {
			case .solid: return nil
		case .dashed: return .init(dashLength: 4.0, dashSpaceLength: 2.0)
			case .gradient: return nil
		}
	}
	
	var gradientOptions: GradientPolylineOptions? {
		switch self {
			case .solid: return nil
			case .dashed: return nil
			case .gradient: return .init(
				borderWidth: 1.0,
				secondBorderWidth: 1.0,
				gradientLength: 4000.0,
				borderColor: .init(.black)!,
				secondBorderColor: .init(.black)!,
				colors: [.init(.red)!, .init(.yellow)!, .init(.green)!, .init(.blue)!, .init(.magenta)!],
				colorIndices: Data([])
			)
		}
	}
}

enum CircleStrokeType: UInt {
	case solid
	case dashed
	
	mutating func next() {
		self = CircleStrokeType(rawValue: self.rawValue + 1) ?? .solid
	}
	
	var text: String {
		switch self {
			case .solid: return "Solid"
			case .dashed: return "Dashed"
		}
	}
	
	var dashedOptions: DashedStrokeCircleOptions? {
		switch self {
			case .solid: return nil
			case .dashed: return DashedStrokeCircleOptions(dashLength: 4.0, dashSpaceLength: 2.0)
		}
	}
}

enum MapObjectType: UInt {
	case circle
	case marker
	case model
	case polygon
	case polyline

	mutating func next() {
		self = MapObjectType(rawValue: self.rawValue + 1) ?? .circle
	}

	var text: String {
		switch self {
			case .circle: return "Circle"
			case .marker: return "Marker"
			case .model: return "Model"
			case .polygon: return "Polygon"
			case .polyline: return "Polyline"
		}
	}
}
