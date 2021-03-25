import PlatformSDK

extension GeoPoint: CustomStringConvertible {

	public var description: String {
		"Latitude: \(self.latitude.value)\nLongitude: \(self.longitude.value)"
	}
}

extension GeoPointWithElevation: CustomStringConvertible {

	public var description: String {
		"Latitude: \(self.latitude.value)\nLongitude: \(self.longitude.value)\nElevation: \(self.elevation.value)"
	}
}
