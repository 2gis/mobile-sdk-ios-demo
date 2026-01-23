import SwiftUI

struct RotationGestureSettingsView: View {
	@ObservedObject private var viewModel: RotationGestureSettingsViewModel
	@Binding var isPresented: Bool

	init(
		viewModel: RotationGestureSettingsViewModel,
		isPresented: Binding<Bool>
	) {
		self.viewModel = viewModel
		self._isPresented = isPresented
	}

	var body: some View {
		NavigationView {
			ScrollView {
				LazyVStack(alignment: .leading, spacing: 12) {
					sectionGestureSetting { self.rotationSwitch() }
					if self.viewModel.rotationEnabled {
						sectionGestureSetting { self.actionPointPicker() }
						sectionGestureSetting { self.makeGestureSettings() }
						sectionGestureSetting { self.rotationKinematicSwitch() }
						if self.viewModel.rotationKinematicEnabled {
							sectionGestureSetting { self.makeKinematicSettings() }
						}
					}
				}
				.padding(.horizontal, 16)
				.padding(.top, 8)
				.background(Color(UIColor.systemGroupedBackground))
			}
			.background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
			.navigationTitle("Rotation settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					self.closeButton()
				}
			}
		}
	}

	private func rotationSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$viewModel.rotationEnabled, label: {
				makeGestureSettingTitle("Rotation enable")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
		}
	}

	private func actionPointPicker() -> some View {
		VStack(alignment: .leading, spacing: 12) {
			makeGestureSettingTitle("ActionPoint")
			Picker("ActionPoint", selection: self.$viewModel.actionPoint) {
				ForEach(ActionPoint.allCases) { point in
					Text(point.title).tag(point)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
		}
	}

	private func makeGestureSettings() -> some View {
		VStack(alignment: .leading) {
			makeGestureSettingTitle("Gesture settings:")
				.padding(.bottom)
			SettingsFormTextFieldView(
				title: "RotationThresholdAngleDiffDeg",
				value: self.$viewModel.rotationThresholdAngleDiffDeg
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "RotationThresholdDistanceDiffMm",
				value: self.$viewModel.rotationThresholdDistanceDiffMm
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "RotationThresholdInScalingAngleDiffDeg",
				value: self.$viewModel.rotationThresholdInScalingAngleDiffDeg
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "RotationThresholdInScalingDistanceDiffMm",
				value: self.$viewModel.rotationThresholdInScalingDistanceDiffMm
			)
		}
	}

	private func rotationKinematicSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$viewModel.rotationKinematicEnabled, label: {
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
				title: "MaxInitialForwardAngularSpeed",
				value: self.$viewModel.maxInitialForwardAngularSpeed
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "InitialBackwardAngularSpeed",
				value: self.$viewModel.initialBackwardAngularSpeed
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "AngleThreshold",
				value: self.$viewModel.angleThreshold
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
