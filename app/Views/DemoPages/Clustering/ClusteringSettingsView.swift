import SwiftUI

struct ClusteringSettingsView: View {
	@SwiftUI.Binding private var isPresented: Bool
	@SwiftUI.Binding private var groupingType: GroupingType
	@SwiftUI.Binding private var objectsCount: UInt32
	@SwiftUI.Binding private var minZoom: UInt32
	@SwiftUI.Binding private var maxZoom: UInt32
	@SwiftUI.Binding private var isVisible: Bool

	private let groupingTypes: [GroupingType] = [
		.clustering,
		.generalization
	]

	init(
		isPresented: Binding<Bool>,
		groupingType: Binding<GroupingType>,
		objectsCount: Binding<UInt32>,
		minZoom: Binding<UInt32>,
		maxZoom: Binding<UInt32>,
		isVisible: Binding<Bool>
	) {
		self._isPresented = isPresented
		self._groupingType = groupingType
		self._objectsCount = objectsCount
		self._minZoom = minZoom
		self._maxZoom = maxZoom
		self._isVisible = isVisible
	}

	var body: some View {
		NavigationView {
			ZStack {
				List {
					self.makeGroupingTypePicker()
					.padding(.bottom)
					self.makeVisibleSwitch()
					.padding(.bottom)
					SettingsFormTextField(
						title: "Number of mutable objects",
						value: self.$objectsCount
					)
					.padding(.bottom)
					SettingsFormTextField(
						title: "Min zoom",
						value: self.$minZoom
					)
					.padding(.bottom)
					SettingsFormTextField(
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
			Text("Закрыть")
		}
	}

	private func makeGroupingTypePicker() -> some View {
		VStack(alignment: .leading) {
			self.makeTitle("Grouping type:")
			Picker(
				selection: self.$groupingType,
				label: Text(""),
				content: {
					ForEach(self.groupingTypes, content: {
						Text($0.title)
					})
				}
			)
			.pickerStyle(SegmentedPickerStyle())
		}
	}

	private func makeVisibleSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$isVisible, label: {
				self.makeTitle("Markers are visible")
			})
		}
	}

	private func makeTitle(_ text: String) -> Text {
		Text(text)
		.fontWeight(.bold)
		.foregroundColor(.black)
	}

}

extension GroupingType: Identifiable {
	public var id: GroupingType {
		self
	}

	fileprivate var title: String {
		switch self {
			case .clustering:
				return "Clustering"
			case .generalization:
				return "Generalization"
		}
	}
}
