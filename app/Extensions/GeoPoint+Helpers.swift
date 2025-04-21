import DGis

extension GeoPoint {

	public var description: String {
		"Latitude: \(self.latitude.value)\nLongitude: \(self.longitude.value)"
	}
}

extension GeoPointWithElevation {

	public var description: String {
		"Latitude: \(self.latitude.value)\nLongitude: \(self.longitude.value)\nElevation: \(self.elevation.value)"
	}
}
