import Foundation
import SwiftUI
import DGis

struct SuggestViewModel: Identifiable, Hashable {
	let id = UUID()
	let title: String
	let subtitle: String?
	let applyHandler: SuggestHandler
	let icon: SwiftUI.Image
	let object: DirectoryObjectViewModel?

	init(suggest: Suggest) {
		self.title = makeTitle(suggest) ?? ""
		self.subtitle = makeSubtitle(suggest)
		self.applyHandler = suggest.handler
		self.icon = makeIcon(for: suggest.handler)
		self.object = suggest.handler.object.map(DirectoryObjectViewModel.init)
	}

	static func ==(_ lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
	}
}

// Формируем title из DirectoryObject и IncompleteTextHandler.
private func makeTitle(_ suggest: Suggest) -> String? {
	switch suggest.handler {
		case .objectHandler(let directoryObject):
			return directoryObject?.item.title
		case .incompleteTextHandler(let incompleteTextHandler):
			return incompleteTextHandler?.queryText
		default:
			return nil
	}
}

// Формируем subtitle из DirectoryObject.
private func makeSubtitle(_ suggest: Suggest) -> String? {
	switch suggest.handler {
		case .objectHandler(let directoryObject):
			var addressComponents: [String] = []
			if let addressStreets = directoryObject?.item.address?.addressStreets {
				let addresses = addressStreets.map { "\($0.street), \($0.number)" }
				addressComponents.append(contentsOf: addresses)
			}
			if let comment = directoryObject?.item.address?.addressComment {
				addressComponents.append(comment)
			}
			return addressComponents.joined(separator: "\n")
		default:
			return nil
	}
}

private func makeIcon(for handler: SuggestHandler) -> SwiftUI.Image {
	let icon: SwiftUI.Image
	switch handler {
		case .objectHandler:
			icon = Image(systemName: "map")
		case .performSearchHandler:
			icon = Image(systemName: "magnifyingglass")
		case .incompleteTextHandler:
			icon = Image(systemName: "text.insert")
		@unknown default:
			fatalError()
	}
	return icon
}

private extension Address {
	var addressStreets: [AddressStreet] {
		return self.components.compactMap {
			if case let .streetAddress(address) = $0 {
				return address
			}
			return nil
		}
	}
}

private extension SuggestHandler {
	var object: DirectoryObject? {
		switch self {
			case .objectHandler(let handler):
				return handler?.item
			default:
				return nil
		}
	}
}
