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
			.navigationBarTitle(Text("Видимые дорожные события"), displayMode: .inline)
			.navigationBarItems(trailing: Button("Закрыть", action: { self.isPresented = false }))
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
			names.append("Камеры")
		}
		if self.contains(.comment) {
			names.append("Комментарии на дорогах")
		}
		if self.contains(.accident) {
			names.append("ДТП")
		}
		if self.contains(.roadRestriction) {
			names.append("Перекрытия дорог")
		}
		if self.contains(.roadWorks) {
			names.append("Дорожные работы")
		}
		if self.contains(.user) {
			names.append("События текущего пользователя")
		}
		if self.contains(.other) {
			names.append("Другое")
		}
		return names.joined(separator: ", ")
	}
}
