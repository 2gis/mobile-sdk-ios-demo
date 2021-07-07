import Foundation
import DGis

struct SearchResultItemViewModel: Identifiable {
	let id = UUID()
	let title: String
	let subtitle: String
	let address: String?
	let object: DirectoryObjectViewModel

	init(_ item: DirectoryObject) {
		self.title = item.title
		self.subtitle = item.subtitle
		self.address = item.formattedAddress(type: .short)?.streetAddress
		self.object = DirectoryObjectViewModel(object: item)
	}
}
