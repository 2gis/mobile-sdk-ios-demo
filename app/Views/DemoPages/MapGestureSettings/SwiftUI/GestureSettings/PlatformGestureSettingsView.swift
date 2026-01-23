import DGis
import SwiftUI

struct PlatformGestureSettingsView: View {
	@ObservedObject private var viewModel: PlatformGestureSettingsViewModel
	@Binding var isPresented: Bool

	init(
		viewModel: PlatformGestureSettingsViewModel,
		isPresented: Binding<Bool>
	) {
		self.viewModel = viewModel
		self._isPresented = isPresented
	}

	var body: some View {
		NavigationView {
			ScrollView {
				LazyVStack(alignment: .leading, spacing: 12) {
					sectionGestureSetting { self.platformGestureSettingsToggles() }
					sectionGestureSetting { self.doubleTapScalingCenterPicker() }
					sectionGestureSetting { self.twoFingerTapScalingCenterPicker() }
					sectionGestureSetting { self.pinchScalingCenterPicker() }
				}
				.padding(.horizontal, 16)
				.padding(.top, 8)
				.background(Color(UIColor.systemGroupedBackground))
			}
			.background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
			.navigationTitle("PlatformGesture settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					self.closeButton()
				}
			}
		}
	}

	private func platformGestureSettingsToggles() -> some View {
		VStack(alignment: .leading) {
			makeGestureSettingTitle("Gesture toggles:")
				.padding(.bottom)
			Toggle(isOn: self.$viewModel.doubleTapGestureRecognizerEnabled, label: {
				makeGestureSettingTitle("DoubleTapGestureRecognizer enable")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			.padding(.bottom, 8)
			Toggle(isOn: self.$viewModel.panGestureRecognizerEnabled, label: {
				makeGestureSettingTitle("PanGestureRecognizer enable")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			.padding(.bottom, 8)
			Toggle(isOn: self.$viewModel.twoFingerPanGestureRecognizerEnabled, label: {
				makeGestureSettingTitle("TwoFingerPanGestureRecognizer enable")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			.padding(.bottom, 8)
			Toggle(isOn: self.$viewModel.rotationGestureRecognizerEnabled, label: {
				makeGestureSettingTitle("RotationGestureRecognizer enable")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			.padding(.bottom, 8)
			Toggle(isOn: self.$viewModel.pinchGestureRecognizerEnabled, label: {
				makeGestureSettingTitle("PinchGestureRecognizerEnabled enable")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			.padding(.bottom, 8)
			Toggle(isOn: self.$viewModel.twoFingerTapGestureRecognizerEnabled, label: {
				makeGestureSettingTitle("TwoFingerTapGestureRecognizer enable")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
			.padding(.bottom, 8)
			Toggle(isOn: self.$viewModel.doubleTapAndPanGestureRecognizerEnabled, label: {
				makeGestureSettingTitle("DoubleTapAndPanGestureRecognizer enable")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
		}
	}

	private func doubleTapScalingCenterPicker() -> some View {
		VStack(alignment: .leading, spacing: 12) {
			makeGestureSettingTitle("DoubleTapScalingCenter")
			Picker("DoubleTapScalingCenter", selection: self.$viewModel.doubleTapScalingCenter) {
				ForEach(MapGestureViewOptions.ScalingCenter.allCases) { option in
					Text(option.title).tag(option)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
		}
	}

	private func twoFingerTapScalingCenterPicker() -> some View {
		VStack(alignment: .leading, spacing: 12) {
			makeGestureSettingTitle("TwoFingerTapScalingCenter")
			Picker("TwoFingerTapScalingCenter", selection: self.$viewModel.twoFingerTapScalingCenter) {
				ForEach(MapGestureViewOptions.ScalingCenter.allCases) { option in
					Text(option.title).tag(option)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
		}
	}

	private func pinchScalingCenterPicker() -> some View {
		VStack(alignment: .leading, spacing: 12) {
			makeGestureSettingTitle("PinchScalingCenter")
			Picker("PinchScalingCenter", selection: self.$viewModel.pinchScalingCenter) {
				ForEach(MapGestureViewOptions.ScalingCenter.allCases) { option in
					Text(option.title).tag(option)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
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

extension MapGestureViewOptions.ScalingCenter: @retroactive CaseIterable, @retroactive Identifiable {
	public var id: MapGestureViewOptions.ScalingCenter {
		self
	}

	public static var allCases: [MapGestureViewOptions.ScalingCenter] {
		[MapGestureViewOptions.ScalingCenter.eventCenter, MapGestureViewOptions.ScalingCenter.cameraPosition]
	}

	var title: String {
		switch self {
		case .eventCenter:
			return "EventCenter"
		case .cameraPosition:
			return "CameraPosition"
		@unknown default:
			assertionFailure("Unknown value for MapGestureViewOptions.ScalingCenter")
			return "Unknown"
		}
	}
}
