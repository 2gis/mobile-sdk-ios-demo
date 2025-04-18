import SwiftUI

struct ClusteringSettingsView: View {
	@Binding private var isPresented: Bool
	@Binding private var groupingType: GroupingType
	@Binding private var mapObjectType: ClusterMapObjectType
	@Binding private var animationIndex: Int32
	@Binding private var objectsCount: UInt32
	@Binding private var groupingWidth: Float
	@Binding private var minZoom: Float
	@Binding private var maxZoom: Float
	@Binding private var isVisible: Bool
	@Binding private var isMapObjectsVisible: Bool
	@Binding private var useTextInCluser: Bool

	init(
		isPresented: Binding<Bool>,
		groupingType: Binding<GroupingType>,
		mapObjectType: Binding<ClusterMapObjectType>,
		animationIndex: Binding<Int32>,
		objectsCount: Binding<UInt32>,
		groupingWidth: Binding<Float>,
		minZoom: Binding<Float>,
		maxZoom: Binding<Float>,
		isVisible: Binding<Bool>,
		isMapObjectsVisible: Binding<Bool>,
		useTextInCluser: Binding<Bool>
	) {
		self._isPresented = isPresented
		self._groupingType = groupingType
		self._mapObjectType = mapObjectType
		self._animationIndex = animationIndex
		self._objectsCount = objectsCount
		self._groupingWidth = groupingWidth
		self._minZoom = minZoom
		self._maxZoom = maxZoom
		self._isVisible = isVisible
		self._isMapObjectsVisible = isMapObjectsVisible
		self._useTextInCluser = useTextInCluser
	}

	var body: some View {
		NavigationView {
			ZStack {
				List {
					self.makeGroupingTypePicker()
						.padding(.bottom)
					self.makeMapObjectTypePicker()
						.padding(.bottom)
					if self.mapObjectType == .model {
						SettingsFormTextField(
							title: "Animation index",
							value: self.$animationIndex
						)
						.padding(.bottom)
					}
					self.makeVisibleSwitch()
						.padding(.bottom)
					self.makeMapObjectsVisibleSwitch()
						.padding(.bottom)
					self.makeTextInCluserSwitch()
						.padding(.bottom)
					SettingsFormTextField(
						title: "Number of mutable objects",
						value: self.$objectsCount
					)
					.padding(.bottom)
					SettingsFormTextField(
						title: "Grouping width",
						value: self.$groupingWidth
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

	private func makeMapObjectTypePicker() -> some View {
		VStack(alignment: .leading) {
			self.makeTitle("Map object type:")
			Picker(
				selection: self.$mapObjectType,
				label: Text(""),
				content: {
					ForEach(ClusterMapObjectType.allCases, content: {
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
				self.makeTitle("MapObjectManager is visible")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
		}
	}

	private func makeMapObjectsVisibleSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$isMapObjectsVisible, label: {
				self.makeTitle("Each object is visible")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
		}
	}

	private func makeTextInCluserSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$useTextInCluser, label: {
				self.makeTitle("Cluster with text")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
		}
	}

	private func makeTitle(_ text: String) -> Text {
		Text(text)
			.fontWeight(.bold)
			.foregroundColor(.primary)
	}

}

extension GroupingType: Identifiable {
	public var id: GroupingType {
		self
	}

	var title: String {
		switch self {
		case .clustering:
			"Clustering"
		case .generalization:
			"Generalization"
		case .noGrouping:
			"WithoutGrouping"
		}
	}
}

extension ClusterMapObjectType: Identifiable {
	public var id: ClusterMapObjectType {
		self
	}

	fileprivate var title: String {
		switch self {
		case .marker:
			"Marker"
		case .lottie:
			"Lottie"
		case .model:
			"Model"
		}
	}
}
