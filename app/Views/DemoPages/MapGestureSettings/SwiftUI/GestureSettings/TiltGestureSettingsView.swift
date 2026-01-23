import SwiftUI

struct TiltGestureSettingsView: View {
	@ObservedObject private var viewModel: TiltGestureSettingsViewModel
	@Binding var isPresented: Bool

	init(
		viewModel: TiltGestureSettingsViewModel,
		isPresented: Binding<Bool>
	) {
		self.viewModel = viewModel
		self._isPresented = isPresented
	}

	var body: some View {
		NavigationView {
			ScrollView {
				LazyVStack(alignment: .leading, spacing: 12) {
					sectionGestureSetting { self.tiltSwitch() }
					if self.viewModel.tiltEnabled {
						sectionGestureSetting { self.makeGestureSettings() }
						sectionGestureSetting { self.tiltKinematicSwitch() }
						if self.viewModel.tiltKinematicEnabled {
							sectionGestureSetting { self.makeKinematicSettings() }
						}
					}
				}
				.padding(.horizontal, 16)
				.padding(.top, 8)
				.background(Color(UIColor.systemGroupedBackground))
			}
			.background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
			.navigationTitle("Tilt settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					self.closeButton()
				}
			}
		}
	}

	private func tiltSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$viewModel.tiltEnabled, label: {
				makeGestureSettingTitle("Tilt enable")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
		}
	}

	private func makeGestureSettings() -> some View {
		VStack(alignment: .leading) {
			makeGestureSettingTitle("Gesture settings:")
				.padding(.bottom)
			SettingsFormTextFieldView(
				title: "LenOnDegreeMm",
				value: self.$viewModel.lenOnDegreeMm
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "HorizontalSwerveDeg",
				value: self.$viewModel.horizontalSwerveDeg
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "VerticalSwerveDeg",
				value: self.$viewModel.verticalSwerveDeg
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "ThresholdMm",
				value: self.$viewModel.thresholdMm
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "MaxParallelsDeviationDeg",
				value: self.$viewModel.maxParallelsDeviationDeg
			)
		}
	}

	private func tiltKinematicSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$viewModel.tiltKinematicEnabled, label: {
				makeGestureSettingTitle("Kinematic enable")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
		}
	}

	private func makeKinematicSettings() -> some View {
		VStack(alignment: .leading) {
			makeGestureSettingTitle("Kinematic settings:")
				.padding(.bottom)
			SettingsFormTextFieldView(
				title: "DecelerationCoefficient",
				value: self.$viewModel.decelerationCoefficient
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "InitialForwardSpeedMultiplier",
				value: self.$viewModel.initialForwardSpeedMultiplier
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "MaxInitialForwardAngularSpeed",
				value: self.$viewModel.maxInitialForwardAngularSpeed
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "MinTiltAdditionalBorder",
				value: self.$viewModel.minTiltAdditionalBorder
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "MaxTiltAdditionalBorder",
				value: self.$viewModel.maxTiltAdditionalBorder
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "TiltThreshold",
				value: self.$viewModel.tiltThreshold
			)
		}
	}

	private func closeButton() -> some View {
		Button {
			self.viewModel.set()
			self.isPresented = false
		} label: {
			Text("Close")
		}
	}
}
