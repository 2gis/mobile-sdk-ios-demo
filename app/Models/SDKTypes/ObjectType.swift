import DGis

extension ObjectType {
	var name: String {
		switch self {
			case .admDiv:
				return "Administrative unit"
			case .attraction:
				return "Attraction"
			case .branch:
				return "Branch"
			case .building:
				return "Building"
			case .coordinates:
				return "Coordinates"
			case .crossroad:
				return "Crossroad"
			case .parking:
				return "Parking"
			case .road:
				return "Road"
			case .route:
				return "Public transport route"
			case .station:
				return "Station"
			case .stationEntrance:
				return "Station entrance"
			case .street:
				return "Street"
			case .unknown:
				return "Unknown objectType"
			@unknown default:
				assertionFailure("Unsupported ObjectType: \(self)")
				return "Unsupported objectType \(self.rawValue)"
		}
	}
}
