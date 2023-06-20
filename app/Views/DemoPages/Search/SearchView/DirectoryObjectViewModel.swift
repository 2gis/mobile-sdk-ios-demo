import DGis

struct DirectoryObjectViewModel {
	let navigationTitle: String
	let title: String
	let subtitle: String
	let markerPosition: GeoPointWithElevation?
	let address: FormattedAddressViewModel?
	let distanceToObject: Meter?

	init(object: DirectoryObject, lastLocation: GeoPoint?) {
		self.navigationTitle = object.title
		self.title = object.title
		self.subtitle = object.subtitle
		self.markerPosition = object.markerPosition

		let formattedAddress = object.formattedAddress(type: .full)
		self.address = formattedAddress.map(FormattedAddressViewModel.init)

		if let location = lastLocation {
			self.distanceToObject = self.markerPosition?.distance(point: location)
		} else {
			self.distanceToObject = nil
		}
	}
}
