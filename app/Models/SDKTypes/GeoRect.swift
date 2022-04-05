import DGis

extension DGis.GeoRect {

	func expanded(by ratio: Double) -> GeoRect {
		let width = self.northEastPoint.longitude.value - self.southWestPoint.longitude.value
		let widthExpansion = width * (ratio - 1)
		let height = self.northEastPoint.latitude.value - self.southWestPoint.latitude.value
		let heightExpansion = height * (ratio - 1)
		return GeoRect(
			southWestPoint: GeoPoint(
				latitude: self.southWestPoint.latitude.value - heightExpansion,
				longitude: self.southWestPoint.longitude.value - widthExpansion
			),
			northEastPoint: GeoPoint(
				latitude: self.northEastPoint.latitude.value + heightExpansion,
				longitude: self.northEastPoint.longitude.value + widthExpansion
			)
		)
	}

	/// *This is a simplified example*.
	func contains(_ rect: GeoRect) -> Bool {
		self.northEastPoint.latitude.value >= rect.northEastPoint.latitude.value
			&& self.northEastPoint.longitude.value >= rect.northEastPoint.longitude.value
			&& self.southWestPoint.latitude.value <= rect.southWestPoint.latitude.value
			&& self.southWestPoint.longitude.value <= rect.southWestPoint.longitude.value
	}
}
