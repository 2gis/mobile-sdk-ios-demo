import DGis
import SwiftUI

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
					if self.viewModel.mapDataSources.count > 1 {
						self.mapSourcePicker()
							.padding(.bottom)
					}
					self.languagePicker()
						.padding(.bottom)
					self.stylesPicker()
						.padding(.bottom)
					self.graphicsOptionPicker()
						.padding(.bottom)
					self.mapThemePicker()
						.padding(.bottom)
					self.geolocationMarkerTypePicker()
						.padding(.bottom)
					self.makeHttpSettings()
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
			CustomStylePickerView(fileURL: self.$viewModel.newStyleURL)
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

	private func stylesPicker() -> some View {
		VStack(alignment: .leading, spacing: 5) {
			HStack {
				Text("Styles")
					.font(.system(size: 20, weight: .bold))
				Spacer()
				Button(action: {
					self.navigationService.present(CustomStylePickerView(fileURL: self.$viewModel.newStyleURL))
				}) {
					Image(systemName: "plus.circle")
						.resizable()
						.frame(width: 24, height: 24)
						.foregroundColor(.accentColor)
				}
				.buttonStyle(PlainButtonStyle())
			}
			.padding(.bottom, 10)
			ForEach(self.viewModel.styles, id: \.self) { style in
				StyleRow(viewModel: self.viewModel, style: style)
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

	private func geolocationMarkerTypePicker() -> some View {
		PickerView(
			title: "Geolocation marker type",
			selection: self.$viewModel.geolocationMarkerType,
			options: self.viewModel.geolocationMarkerTypes,
			pickerStyle: .segmented
		)
	}

	private func makeHttpSettings() -> some View {
		VStack(alignment: .leading) {
			self.makeTitle("Network settings:")
				.padding(.bottom)
			self.httpCacheSwitch()
				.padding(.bottom, 8)
			self.httpTimeoutValue()
		}
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

	private func httpTimeoutValue() -> some View {
		VStack(alignment: .leading) {
			SettingsFormTextField(
				title: "Network timeout, s: ",
				value: self.$viewModel.httpTimeout
			)
		}
	}

	private func makeLoggerSettings() -> some View {
		VStack(alignment: .leading) {
			self.makeTitle("Logging:")
			HStack {
				Text("SDK log level: ") + Text("\(self.viewModel.logLevel.name)").bold()
				Spacer()
				Image(systemName: "chevron.right")
			}
			.frame(height: 44)
			.contentShape(Rectangle())
			.onTapGesture(perform: {
				self.viewModel.selectLogLevel()
			})
			HStack {
				Text("Log files")
				Spacer()
				Image(systemName: "chevron.right")
			}
			.frame(height: 44)
			.contentShape(Rectangle())
			.onTapGesture(perform: {
				self.showLogs()
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
			title: Text("SDK log level").bold(),
			message: Text("Application restart requred"),
			buttons: buttons
		)
	}

	private func muteOtherSoundsSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$viewModel.muteOtherSounds, label: {
				self.makeTitle("Mute sounds of other apps")
			})
		}
	}

	private func addRoadEventSourceInNavigationViewSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$viewModel.addRoadEventSourceInNavigationView, label: {
				self.makeTitle("Add road events source to navigator example")
			})
		}
	}

	private func graphicsOptionPicker() -> some View {
		PickerView(
			title: "Graphics Option",
			selection: self.$viewModel.graphicsOption,
			options: self.viewModel.graphicsOptions,
			pickerStyle: SegmentedPickerStyle()
		)
	}

	private func makeNavigatorSettings() -> some View {
		VStack(alignment: .leading) {
			self.makeTitle("Navigator settings:")
				.padding(.bottom)
			self.navigatorVoiceVolumeSlider()
				.padding(.bottom, 8)
			self.navigatorControlsPicker()
				.padding(.bottom, 8)
			self.muteOtherSoundsSwitch()
				.padding(.bottom, 8)
			self.addRoadEventSourceInNavigationViewSwitch()
				.padding(.bottom, 8)
			self.navigatorThemePicker()
				.padding(.bottom, 8)
			self.navigatorDashboardButtonPicker()
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

	private func navigatorVoiceVolumeSlider() -> some View {
		VStack(alignment: .leading) {
			Text("Sound level: \(Int(self.viewModel.navigatorVoiceVolume))")
				.font(.system(size: 20, weight: .bold))
			Slider(
				value: self.$viewModel.navigatorVoiceVolume,
				in: 0 ... 100,
				step: 1
			)
		}
	}

	private func navigatorControlsPicker() -> some View {
		PickerView(
			title: "Navigator controls",
			selection: self.$viewModel.navigatorControls,
			options: self.viewModel.navigatorControlsList,
			pickerStyle: SegmentedPickerStyle()
		)
	}

	private func navigatorDashboardButtonPicker() -> some View {
		PickerView(
			title: "Navigator dashboard button",
			selection: self.$viewModel.navigatorDashboardButton,
			options: self.viewModel.navigatorDashboardButtons,
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

	private func showLogs() {
		let viewModel = LogFileListViewModel(logger: self.viewModel.logger)
		let view = LogFileListView(viewModel: viewModel)
		self.navigationService.push(view)
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
		case .off:
			return "Disabled"
		case .verbose:
			return "Verbose"
		case .info:
			return "Info"
		case .error:
			return "Error"
		case .warning:
			return "Warning"
		case .fatal:
			return "Fault"
		@unknown default:
			assertionFailure("Unknown type: \(self)")
			return "Unknown type: \(self.rawValue)"
		}
	}
}
