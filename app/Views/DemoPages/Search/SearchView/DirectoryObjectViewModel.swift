import PlatformMapSDK

struct DirectoryObjectViewModel {
	let navigationTitle: String
	let title: String
	let subtitle: String
	let address: FormattedAddressViewModel?

	init(object: DirectoryObject) {
		self.navigationTitle = object.title
		self.title = object.title
		self.subtitle = object.subtitle

		let formattedAddress = object.formattedAddress(type: .full)
		self.address = formattedAddress.map(FormattedAddressViewModel.init)
	}
}
