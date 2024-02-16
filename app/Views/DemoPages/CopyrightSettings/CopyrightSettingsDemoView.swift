import SwiftUI
import DGis

struct CopyrightSettingsDemoView: View {
	@ObservedObject private var viewModel: CopyrightSettingsDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: CopyrightSettingsDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack {
			self.viewFactory.makeMapViewWithZoomControl(
				alignment: self.viewModel.alignment,
				copyrightInsets: self.viewModel.insets,
				showsAPIVersion: self.viewModel.showsAPIVersion
			)
		}
		.sheet(isPresented: self.$viewModel.showSettings) {
			CopyrightSettingsView(
				isPresented: self.$viewModel.showSettings,
				alignment: self.$viewModel.alignment,
				showsAPIVersion: self.$viewModel.showsAPIVersion,
				insets: self.$viewModel.insets
			)
		}
		.navigationBarItems(trailing: self.settingsButton())
		.edgesIgnoringSafeArea(.all)
	}

	private func settingsButton() -> some View {
		Button {
			self.viewModel.showSettings = true
		} label: {
			Image(systemName: "gear")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 30)
		}
	}
}

private struct CopyrightSettingsView: View {
	@SwiftUI.Binding private var isPresented: Bool
	@SwiftUI.Binding private var alignment: CopyrightAlignment
	@SwiftUI.Binding private var showsAPIVersion: Bool
	@SwiftUI.Binding private var topInset: CGFloat
	@SwiftUI.Binding private var leftInset: CGFloat
	@SwiftUI.Binding private var bottomInset: CGFloat
	@SwiftUI.Binding private var rightInset: CGFloat

	private let alignments: [CopyrightAlignment] = [
		.bottomLeft,
		.bottomRight,
		.topLeft,
		.topRight
	]

	init(
		isPresented: Binding<Bool>,
		alignment: Binding<CopyrightAlignment>,
		showsAPIVersion: Binding<Bool>,
		insets: Binding<UIEdgeInsets>
	) {
		self._isPresented = isPresented
		self._alignment = alignment
		self._showsAPIVersion = showsAPIVersion
		self._topInset = insets.top
		self._leftInset = insets.left
		self._bottomInset = insets.bottom
		self._rightInset = insets.right
	}

	var body: some View {
		NavigationView {
			ZStack {
				List {
					self.makeApiVersionSwitch()
					.padding(.bottom)
					self.makeAlignmentPicker()
					.padding(.bottom)
					self.makeTitle("Insets:")
					self.makeInsetsSlider(
						title: "Top",
						value: self.$topInset,
						maxValue: UIScreen.main.bounds.size.height
					)
					self.makeInsetsSlider(
						title: "Left",
						value: self.$leftInset,
						maxValue: UIScreen.main.bounds.size.width
					)
					self.makeInsetsSlider(
						title: "Bottom",
						value: self.$bottomInset,
						maxValue: UIScreen.main.bounds.size.height
					)
					self.makeInsetsSlider(
						title: "Right",
						value: self.$rightInset,
						maxValue: UIScreen.main.bounds.size.width
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

	private func makeAlignmentPicker() -> some View {
		VStack(alignment: .leading) {
			self.makeTitle("Aligning:")
			Picker(
				selection: self.$alignment,
				label: Text(""),
				content: {
					ForEach(self.alignments, content: {
						Text($0.title)
					})
				}
			)
			.pickerStyle(SegmentedPickerStyle())
		}
	}

	private func makeApiVersionSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$showsAPIVersion, label: {
				self.makeTitle("Show API version")
			})
		}
	}

	private func makeInsetsSlider(
		title: String,
		value: Binding<CGFloat>,
		maxValue: CGFloat
	) -> some View {
		HStack {
			self.makeTitle("\(title) \(value.wrappedValue)")
			Slider(value: value, in: 0...maxValue, step: 1)
		}
	}

	private func makeTitle(_ text: String) -> Text {
		Text(text)
		.fontWeight(.bold)
		.foregroundColor(.black)
	}

}

extension CopyrightAlignment: Identifiable {
	public var id: CopyrightAlignment {
		self
	}

	fileprivate var title: String {
		switch self {
			case .bottomLeft:
				return "BottomLeft"
			case .bottomRight:
				return "BottomRight"
			case .topLeft:
				return "TopLeft"
			case .topRight:
				return "TopRight"
			@unknown default:
				return "BottomLeft"
		}
	}
}
