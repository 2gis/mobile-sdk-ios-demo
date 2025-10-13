import CoreLocation

struct Zones: Decodable {
	let areas: [String: [Location]]
	let areaGroups: [String: [String]]

	enum CodingKeys: String, CodingKey {
		case areas
		case areaGroups = "area_groups"
	}

	func polygons(areaId: String) -> [[CLLocationCoordinate2D]] {
		var polygons = [[CLLocationCoordinate2D]]()
		guard let groupOfAreas = areaGroups[areaId] else { return [] }

		for groupID in groupOfAreas {
			var points = [CLLocationCoordinate2D]()
			let group = self.areas[groupID] ?? []

			if group.count < 2 {
				continue
			}

			for location in group {
				points.append(CLLocationCoordinate2D(
					latitude: location.lat,
					longitude: location.lon
				))
			}
			polygons.append(points)
		}
		return polygons
	}
}
