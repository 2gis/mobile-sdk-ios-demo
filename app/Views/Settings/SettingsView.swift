import SwiftUI
import DGis

struct SettingsView: View {
	@Binding private var show: Bool
	@ObservedObject private var viewModel: SettingsViewModel
	@EnvironmentObject private var navigationService: NavigationService
	@SwiftUI.State private var isStylePickerPresented: Bool = false

	init(viewModel: SettingsViewModel, show: Binding<Bool>) {
		self.viewModel = viewModel
		self._show = show
	}

	var body: some View {
		NavigationView {
			ZStack {
				List {
					self.mapSourcePicker()
					.padding(.bottom)
					self.languagePicker()
					.padding(.bottom)
					self.loadCustomStyles()
					.padding(.bottom)
					self.mapThemePicker()
					.padding(.bottom)
					self.httpCacheSwitch()
					.padding(.bottom)
					self.makeLoggerSettings()
					.padding(.bottom)
					self.makeNavigatorSettings()
					.padding(.bottom)
				}
			}
			.actionSheet(isPresented: self.$viewModel.logLevelActionSheetShown) {
				self.makeLogLevelActionSheet()
			}
			.navigationBarItems(trailing: self.closeButton())
			.navigationBarTitle(Text("Settings"), displayMode: .inline)
		}
		.sheet(isPresented: self.$isStylePickerPresented, content: {
			CustomStylePickerView(fileURL: self.$viewModel.customStyleUrl)
		})
	}

	private func mapSourcePicker() -> some View {
		PickerView(
			title: "Map data source",
			selection: self.$viewModel.mapDataSource,
			options: self.viewModel.mapDataSources,
			pickerStyle: SegmentedPickerStyle()
		)
	}

	private func languagePicker() -> some View {
		Picker(
			"Map language",
			selection: self.$viewModel.language
		) {
			ForEach(Language.allCases) { lang in
				Text(lang.name).tag(lang)
			}
		}
	}

	private func loadCustomStyles() -> some View {
		HStack {
			Text("Custom styles:")
			Spacer()
			Button(action: {
				if self.viewModel.customStyleUrl == nil {
					self.isStylePickerPresented = true
				} else {
					self.viewModel.customStyleUrl = nil
					self.viewModel.customStyleChoosen = false
				}
			}) {
				Text(self.viewModel.customStyleChoosen ? "Reset styles" : "Choose styles")
				.padding()
				.background(self.viewModel.customStyleChoosen ? Color.red : Color.gray)
				.foregroundColor(.white)
				.cornerRadius(15)
				.font(.callout)
			}
		}
	}

	private func mapThemePicker() -> some View {
		PickerView(
			title: "Map theme",
			selection: self.$viewModel.mapTheme,
			options: self.viewModel.mapThemes,
			pickerStyle: SegmentedPickerStyle()
		)
	}

	private func httpCacheSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$viewModel.httpCacheEnabled, label: {
				Text("HTTP cache")
				.fontWeight(.bold)
				.foregroundColor(.primaryTitle)
			})
		}
	}

	private func makeLoggerSettings() -> some View {
		VStack(alignment: .leading) {
			self.makeTitle("Logging:")
			HStack {
				Text("Logging level SDK: ") + Text("\(self.viewModel.logLevel.name)").bold()
				Spacer()
				Image(systemName: "chevron.right")
			}
			.frame(height: 44)
			.contentShape(Rectangle())
			.onTapGesture(perform: {
				self.viewModel.selectLogLevel()
			})
		}
	}

	private func makeLogLevelActionSheet() -> ActionSheet {
		var buttons: [ActionSheet.Button] = self.viewModel.logLevels.map { level in
			.default(Text(level.name)) {
				self.viewModel.logLevel = level
			}
		}
		buttons.append(.cancel(Text("Cancel")))

		return ActionSheet(
			title: Text("Logging level SDK").bold(),
			message: Text("Need restart application"),
			buttons: buttons
		)
	}
	
	private func muteOtherSoundsSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$viewModel.muteOtherSounds, label: {
				self.makeTitle("Mute other sounds")
			})
		}
	}

	private func addRoadEventSourceInNavigationViewSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$viewModel.addRoadEventSourceInNavigationView, label: {
				self.makeTitle("Add road event source in NavigationView")
			})
		}
	}

	private func makeNavigatorSettings() -> some View {
		VStack(alignment: .leading) {
			self.makeTitle("Navigator settings:")
			.padding(.bottom)
			self.navigatorVoiceVolumePicker()
			.padding(.bottom, 8)
			self.muteOtherSoundsSwitch()
			.padding(.bottom, 8)
			self.addRoadEventSourceInNavigationViewSwitch()
			.padding(.bottom, 8)
			self.navigatorThemePicker()
		}
	}

	private func navigatorThemePicker() -> some View {
		PickerView(
			title: "Navigator theme",
			selection: self.$viewModel.navigatorTheme,
			options: self.viewModel.navigatorThemes,
			pickerStyle: SegmentedPickerStyle()
		)
	}

	private func navigatorVoiceVolumePicker() -> some View {
		PickerView(
			title: "Sound level",
			selection: self.$viewModel.navigatorVoiceVolumeSource,
			options: self.viewModel.navigatorVoiceVolumeSources,
			pickerStyle: SegmentedPickerStyle()
		)
	}

	private func closeButton() -> some View {
		Button {
			self.show = false
		} label: {
			Text("Close")
		}
	}

	private func makeTitle(_ text: String) -> Text {
		Text(text)
		.font(.system(size: 20))
		.fontWeight(.bold)
		.foregroundColor(.primaryTitle)
	}
}

extension MapDataSource: PickerViewOption {
	var id: MapDataSource {
		self
	}
}

extension DGis.LogLevel: PickerViewOption {
	public var id: DGis.LogLevel {
		self
	}
	
	var name: String {
		switch self {
			case .disabled:
				return "Disabled"
			case .verbose:
				return "Verbose"
			case .info:
				return "Info"
			case .error:
				return "Error"
			case .warning:
				return "Warning"
			case .fault:
				return "Fault"
			@unknown default:
				assertionFailure("Unknown type: \(self)")
				return "Unknown type: \(self.rawValue)"
		}
	}
}
