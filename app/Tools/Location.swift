import CoreLocation

struct Location: Codable, Equatable {
	let lat: Double
	let lon: Double

	enum CodingKeys: String, CodingKey {
		case lat
		case lon
		case latitude
		case longitude
	}

	var as2dLocation: CLLocationCoordinate2D {
		CLLocationCoordinate2D(latitude: self.lat, longitude: self.lon)
	}

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)

		do {
			self.lat = try container.decode(Double.self, forKey: .lat)
		} catch {
			self.lat = try container.decode(Double.self, forKey: .latitude)
		}

		do {
			self.lon = try container.decode(Double.self, forKey: .lon)
		} catch {
			self.lon = try container.decode(Double.self, forKey: .longitude)
		}
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(self.lat, forKey: .lat)
		try container.encode(self.lon, forKey: .lon)
	}

	init(lat: Double, lon: Double) {
		self.lat = lat
		self.lon = lon
	}

	init(location: CLLocationCoordinate2D) {
		self.lat = location.latitude
		self.lon = location.longitude
	}
}
