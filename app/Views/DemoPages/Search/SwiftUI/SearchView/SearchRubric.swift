import DGis
import Foundation

enum SearchRubric: String, CaseIterable {
	case cafe, restaurants, hotels, schools, mosque, gasStation, chargingStation
}

extension SearchRubric: PickerViewOption {
	var id: SearchRubric {
		self
	}

	var name: String {
		switch self {
		case .cafe:
			return "Cafe"
		case .restaurants:
			return "Restaurants"
		case .hotels:
			return "Hotels"
		case .schools:
			return "Schools"
		case .mosque:
			return "Mosque"
		case .gasStation:
			return "Gas Station"
		case .chargingStation:
			return "Charging Station"
		@unknown default:
			assertionFailure("Unknown type: \(self)")
		}
	}

	var value: RubricId {
		switch self {
		case .cafe:
			return .init(value: 161)
		case .restaurants:
			return .init(value: 164)
		case .hotels:
			return .init(value: 269)
		case .schools:
			return .init(value: 245)
		case .mosque:
			return .init(value: 13374)
		case .gasStation:
			return .init(value: 18547)
		case .chargingStation:
			return .init(value: 110320)
		@unknown default:
			assertionFailure("Unknown type: \(self)")
		}
	}
}

extension SearchRubric {
	init?(rubricId: RubricId) {
		if let first = SearchRubric.allCases.first(where: { $0.value == rubricId }) {
			self = first
		} else {
			return nil
		}
	}
}
