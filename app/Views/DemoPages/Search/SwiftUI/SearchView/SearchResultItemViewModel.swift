import Foundation
import DGis

struct SearchResultItemViewModel: Identifiable {
	let id = UUID()
	let title: String
	let subtitle: String
	let address: String?
	let object: DirectoryObjectViewModel
	let reviews: Reviews?
	let distance: Meter?
	let hasEVCharging: Bool

	init(item: DirectoryObject, lastLocation: GeoPoint?) {
		self.title = item.title
		self.subtitle = item.subtitle
		self.address = item.formattedAddress(type: .short)?.streetAddress
		if let location = lastLocation {
			self.distance = item.markerPosition?.distance(point: location)
		} else {
			self.distance = nil
		}
		self.reviews = item.reviews
		self.hasEVCharging = item.chargingStation != nil
		self.object = DirectoryObjectViewModel(object: item, lastLocation: lastLocation)
	}
}
