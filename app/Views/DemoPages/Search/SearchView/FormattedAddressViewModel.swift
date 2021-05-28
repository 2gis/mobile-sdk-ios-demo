import PlatformMapSDK

struct FormattedAddressViewModel {
	let drilldown: String?
	let street: String?
	let comment: String?
	let postCode: String?

	init(address: FormattedAddress) {
		self.drilldown = address.drilldownAddress
		self.street = address.streetAddress
		self.comment = address.addressComment
		self.postCode = address.postCode
	}
}
