import DGis
import SwiftUI

extension DGis.StatusType {
	var name: String {
		switch self {
		case .available:
			return "Available"
		case .charging:
			return "Charging"
		case .reserved:
			return "Reserved"
		case .unavailable:
			return "Unavailable"
		case .unknown:
			return "Unknown Type"
		@unknown default:
			assertionFailure("Unsupported ObjectType: \(self)")
			return "Unsupported Type \(self.rawValue)"
		}
	}

	var color: SwiftUI.Color {
		switch self {
		case .available:
			return .green
		case .charging:
			return .orange
		case .reserved:
			return .yellow
		case .unavailable:
			return .gray
		case .unknown:
			return .black
		@unknown default:
			assertionFailure("Unsupported ObjectType: \(self)")
			return .black
		}
	}
}
