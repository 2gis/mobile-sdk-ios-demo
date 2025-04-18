import DGis

struct FormattedAddressViewModel {
	let drilldown: String?
	let street: String?
	let comment: String?
	let postCode: String?
	let fiasCodes: String?

	init(address: FormattedAddress, addressComponents: [AddressComponent]) {
		self.drilldown = address.drilldownAddress
		self.street = address.streetAddress
		self.comment = address.addressComment
		self.postCode = address.postCode

		let mappedFiasCodes: String? = !addressComponents.isEmpty ? addressComponents.map {
			switch $0 {
			case .streetAddress(let street):
				return street.fiasCode ?? ""
			case .number(let number):
				return number.fiasCode ?? ""
			case .location(_):
				return ""
			@unknown default:
				assertionFailure("Unsupported address Component \($0)")
				return "Unsupported address Component"
			}
		}.joined(separator: ", ") : nil

		self.fiasCodes = mappedFiasCodes
	}
}
