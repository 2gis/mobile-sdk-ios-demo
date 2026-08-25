import DGis
import Foundation
import SwiftUI

struct SearchHistoryItemViewModel: Identifiable {
	let id = UUID()
	let title: String
	let subtitle: String
	let icon: SwiftUI.Image
	let item: SearchHistoryItem
	let objectViewModel: DirectoryObjectViewModel?

	init(item: SearchHistoryItem) {
		switch item {
		case let .searchQuery(query):
			if query.title.isEmpty {
				self.title = query.rubrics.map {
					SearchRubric(rubricId: $0)?.name ?? "Unknown"
				}.joined(separator: ", ")
				self.subtitle = "search by rubric"
			} else {
				self.title = query.title
				self.subtitle = query.subtitle
			}
			self.icon = Image(systemName: "magnifyingglass")
			self.objectViewModel = nil
		case let .directoryObject(object):
			self.objectViewModel = DirectoryObjectViewModel(object: object, lastLocation: nil)
			self.title = object.title

			var sub = object.subtitle
			if let addr = object.formattedAddress(type: FormattingType.full)?.streetAddress {
				sub = sub + ", " + addr
			}

			self.subtitle = sub
			self.icon = Image(systemName: "map")
		@unknown default:
			fatalError("Unknown type: \(item)")
		}
		self.item = item
	}
}
