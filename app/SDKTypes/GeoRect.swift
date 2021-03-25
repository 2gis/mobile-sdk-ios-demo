import PlatformSDK

extension PlatformSDK.GeoRect {

	func expanded(by ratio: Double) -> GeoRect {
		let width = self.longitudeEast - self.longitudeWest
		let widthExpansion = width * (ratio - 1)
		let height = self.latitudeNorth - self.latitudeSouth
		let heightExpansion = height * (ratio - 1)
		return GeoRect(
			latitudeNorth: self.latitudeNorth + heightExpansion,
			latitudeSouth: self.latitudeSouth - heightExpansion,
			longitudeWest: self.longitudeWest - widthExpansion,
			longitudeEast: self.longitudeEast + widthExpansion
		)
	}

	func contains(_ rect: GeoRect) -> Bool {
		self.latitudeNorth >= rect.latitudeNorth
			&& self.latitudeSouth <= rect.latitudeSouth
			&& self.longitudeEast >= rect.longitudeEast
			&& self.longitudeWest <= rect.longitudeWest
	}
}
