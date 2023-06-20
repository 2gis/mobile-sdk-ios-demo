import Foundation
import SwiftUI
import DGis

struct SuggestViewModel: Identifiable, Hashable {
	let id = UUID()
	let title: MarkedUpText
	let subtitle: MarkedUpText
	let applyHandler: SuggestHandler
	let icon: SwiftUI.Image
	let object: DirectoryObjectViewModel?

	init(suggest: Suggest, lastLocation: GeoPoint?) {
		self.title = suggest.title
		self.subtitle = suggest.subtitle
		self.applyHandler = suggest.handler
		self.icon = makeIcon(for: suggest.handler)
		self.object = suggest.handler.object.map { DirectoryObjectViewModel(object: $0, lastLocation: lastLocation) }
	}

	static func ==(_ lhs: Self, rhs: Self) -> Bool {
		lhs.id == rhs.id
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(self.id)
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
