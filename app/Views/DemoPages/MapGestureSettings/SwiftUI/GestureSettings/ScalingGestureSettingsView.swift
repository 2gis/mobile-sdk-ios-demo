import SwiftUI

struct ScalingGestureSettingsView: View {
	@ObservedObject private var viewModel: ScalingGestureSettingsViewModel
	@Binding var isPresented: Bool

	init(
		viewModel: ScalingGestureSettingsViewModel,
		isPresented: Binding<Bool>
	) {
		self.viewModel = viewModel
		self._isPresented = isPresented
	}

	var body: some View {
		NavigationView {
			ScrollView {
				LazyVStack(alignment: .leading, spacing: 12) {
					sectionGestureSetting { self.scalingSwitch() }
					if self.viewModel.scalingEnabled {
						sectionGestureSetting { self.actionPointPicker() }
						sectionGestureSetting { self.makeGestureSettings() }
						sectionGestureSetting { self.scalingKinematicSwitch() }
						if self.viewModel.scalingKinematicEnabled {
							sectionGestureSetting { self.makeKinematicSettings() }
						}
					}
				}
				.padding(.horizontal, 16)
				.padding(.top, 8)
				.background(Color(UIColor.systemGroupedBackground))
			}
			.background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
			.navigationTitle("Scaling settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					self.closeButton()
				}
			}
		}
	}

	private func scalingSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$viewModel.scalingEnabled, label: {
				makeGestureSettingTitle("Scaling enable")
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
				title: "ScaleRatioThreshold",
				value: self.$viewModel.scaleRatioThreshold
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "ScaleRatioThresholdInRotation",
				value: self.$viewModel.scaleRatioThresholdInRotation
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "ZoomScaleRatio",
				value: self.$viewModel.zoomScaleRatio
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "ScaleLogDiffPerMm",
				value: self.$viewModel.scaleLogDiffPerMm
			)
			.padding(.bottom, 8)
			Toggle(isOn: self.$viewModel.disableZoom, label: {
				makeGestureSettingTitle("Disable zoom")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
		}
	}

	private func scalingKinematicSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$viewModel.scalingKinematicEnabled, label: {
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
				title: "MaxInitialForwardZoomSpeed",
				value: self.$viewModel.maxInitialForwardZoomSpeed
			)
			.padding(.bottom, 8)
			SettingsFormTextFieldView(
				title: "ZoomThreshold",
				value: self.$viewModel.zoomThreshold
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
