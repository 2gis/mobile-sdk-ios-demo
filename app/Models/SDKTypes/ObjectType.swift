import DGis

extension ObjectType {
	var name: String {
		switch self {
			case .admDiv:
				return "Administrative unit"
			case .admDivCity:
				return "City"
			case .admDivCountry:
				return "Country"
			case .admDivDistrict:
				return "District"
			case .admDivDistrictArea:
				return "District area"
			case .admDivDivision:
				return "Area"
			case .admDivLivingArea:
				return "Residential community, neighborhood"
			case .admDivPlace:
				return "Parks, beaches, recreation centers, lakes and other places"
			case .admDivRegion:
				return "Region (region/province/republic, etc.)"
			case .admDivSettlement:
				return "Settlement"
			case .attraction:
				return "Attraction"
			case .branch:
				return "Company branch"
			case .building:
				return "Building"
			case .coordinates:
				return "Global coordinate in the WGS84 coordinate system"
			case .crossroad:
				return "Crossroad"
			case .gate:
				return "Passage/thoroughfare"
			case .kilometerRoadSign:
				return "Kilometer road sign"
			case .parking:
				return "Parking lot"
			case .road:
				return "Road"
			case .route:
				return "Route"
			case .station:
				return "Public transport stop or station"
			case .stationEntrance:
				return "The entrance to the station"
			case .stationMetro:
				return "Metro station"
			case .stationPlatform:
				return "Stopping platform"
			case .street:
				return "Street"
			case .unknown:
				return "Unknown type"
			@unknown default:
				assertionFailure("Unsupported ObjectType: \(self)")
				return "Unknown type \(self.rawValue)"
		}
	}
}
