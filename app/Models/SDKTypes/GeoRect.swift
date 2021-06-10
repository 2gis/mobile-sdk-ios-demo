import PlatformMapSDK

extension PlatformMapSDK.GeoRect {

	func expanded(by ratio: Double) -> GeoRect {
		let width = self.northEastPoint.longitude - self.southWestPoint.longitude
		let widthExpansion = width * (ratio - 1)
		let height = self.northEastPoint.latitude - self.southWestPoint.latitude
		let heightExpansion = height * (ratio - 1)
		return GeoRect(
			southWestPoint: GeoPoint(
				latitude: self.southWestPoint.latitude - heightExpansion,
				longitude: self.southWestPoint.longitude - widthExpansion
			),
			northEastPoint: GeoPoint(
				latitude: self.northEastPoint.latitude + heightExpansion,
				longitude: self.northEastPoint.longitude + widthExpansion
			)
		)
	}

	/// *This is a simplified example*.
	func contains(_ rect: GeoRect) -> Bool {
		self.northEastPoint.latitude >= rect.northEastPoint.latitude
			&& self.northEastPoint.longitude >= rect.northEastPoint.longitude
			&& self.southWestPoint.latitude <= rect.southWestPoint.latitude
			&& self.southWestPoint.longitude <= rect.southWestPoint.longitude
	}
}
