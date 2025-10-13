import SwiftUI

struct MapObjectsSettingsView: View {
	typealias Binding = SwiftUI.Binding

	@Binding private var isPresented: Bool
	@Binding private var groupingType: GroupingType
	@Binding private var groupingWidth: Float
	@Binding private var minZoom: Float
	@Binding private var maxZoom: Float

	init(
		isPresented: Binding<Bool>,
		groupingType: Binding<GroupingType>,
		groupingWidth: Binding<Float>,
		minZoom: Binding<Float>,
		maxZoom: Binding<Float>
	) {
		self._isPresented = isPresented
		self._groupingType = groupingType
		self._groupingWidth = groupingWidth
		self._minZoom = minZoom
		self._maxZoom = maxZoom
	}

	var body: some View {
		NavigationView {
			ZStack {
				List {
					self.makeGroupingTypePicker()
					SettingsFormTextFieldView(
						title: "Grouping width",
						value: self.$groupingWidth
					)
					.padding(.bottom)
					SettingsFormTextFieldView(
						title: "Min zoom",
						value: self.$minZoom
					)
					.padding(.bottom)
					SettingsFormTextFieldView(
						title: "Max zoom",
						value: self.$maxZoom
					)
					.padding(.bottom)
				}
			}
			.navigationBarItems(trailing: self.closeButton())
		}
	}

	private func closeButton() -> some View {
		Button {
			self.isPresented = false
		} label: {
			Text("Close")
		}
	}

	private func makeGroupingTypePicker() -> some View {
		VStack(alignment: .leading) {
			self.makeTitle("Grouping type:")
			Picker(
				selection: self.$groupingType,
				label: Text(""),
				content: {
					ForEach(GroupingType.allCases, content: {
						Text($0.title)
					})
				}
			)
			.pickerStyle(SegmentedPickerStyle())
		}
	}

	private func makeTitle(_ text: String) -> Text {
		Text(text)
			.fontWeight(.bold)
			.foregroundColor(.primary)
	}

}
