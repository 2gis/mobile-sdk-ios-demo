import SwiftUI
import DGis

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

extension RoadEventDisplayCategoryOptionSet: Identifiable {
	public var id: RoadEventDisplayCategoryOptionSet{
		self
	}

	fileprivate static var allValues: [RoadEventDisplayCategoryOptionSet] {
		[.camera, .comment, .accident, .roadRestriction, .roadWorks, .user, .other]
	}

	fileprivate var name: String {
		var names: [String] = []
		if self.contains(.camera) {
			names.append("Camera")
		}
		if self.contains(.comment) {
			names.append("Comments on roads")
		}
		if self.contains(.accident) {
			names.append("Accident")
		}
		if self.contains(.roadRestriction) {
			names.append("Road restrictions")
		}
		if self.contains(.roadWorks) {
			names.append("Road works")
		}
		if self.contains(.user) {
			names.append("Current user's events")
		}
		if self.contains(.other) {
			names.append("Others")
		}
		return names.joined(separator: ", ")
	}
}
