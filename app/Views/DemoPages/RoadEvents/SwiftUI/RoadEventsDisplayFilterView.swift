import DGis
import SwiftUI

struct RoadEventsDisplayFilterView: View {
	@Binding private var isPresented: Bool
	@Binding private var visibleEvents: RoadEventDisplayCategoryOptionSet

	init(isPresented: Binding<Bool>, visibleEvents: Binding<RoadEventDisplayCategoryOptionSet>) {
		self._isPresented = isPresented
		self._visibleEvents = visibleEvents
	}

	var body: some View {
		NavigationView {
			List(RoadEventDisplayCategoryOptionSet.allValues) { event in
				Button(
					action: {
						if self.visibleEvents.remove(event) == nil {
							self.visibleEvents.insert(event)
						}
					}, label: {
						HStack {
							Text(event.name)
							Spacer()
							if self.visibleEvents.contains(event) {
								Image(systemName: "checkmark")
							}
						}
					}
				)
			}
			.navigationBarTitle(Text("Visible road events"), displayMode: .inline)
			.navigationBarItems(trailing: Button("Close", action: { self.isPresented = false }))
		}
	}
}

extension RoadEventDisplayCategoryOptionSet: @retroactive Identifiable {
	public var id: RoadEventDisplayCategoryOptionSet {
		self
	}

	static var allValues: [RoadEventDisplayCategoryOptionSet] {
		[.camera, .comment, .accident, .roadRestriction, .roadWorks, .user, .other]
	}

	var name: String {
		var names: [String] = []
		if self.contains(.camera) {
			names.append("Cameras")
		}
		if self.contains(.comment) {
			names.append("Road comments")
		}
		if self.contains(.accident) {
			names.append("Accidents")
		}
		if self.contains(.roadRestriction) {
			names.append("Road restriction")
		}
		if self.contains(.roadWorks) {
			names.append("Road works")
		}
		if self.contains(.user) {
			names.append("Current user events")
		}
		if self.contains(.other) {
			names.append("Other")
		}
		return names.joined(separator: ", ")
	}
}
