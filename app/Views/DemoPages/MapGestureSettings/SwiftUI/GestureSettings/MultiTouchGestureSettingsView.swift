import SwiftUI

struct MultiTouchGestureSettingsView: View {
	@ObservedObject private var viewModel: MultiTouchGestureSettingsViewModel
	@Binding var isPresented: Bool

	init(
		viewModel: MultiTouchGestureSettingsViewModel,
		isPresented: Binding<Bool>
	) {
		self.viewModel = viewModel
		self._isPresented = isPresented
	}

	var body: some View {
		NavigationView {
			ScrollView {
				LazyVStack(alignment: .leading, spacing: 12) {
					sectionGestureSetting { self.multiTouchSwitch() }
					if self.viewModel.multiTouchEnabled {
						sectionGestureSetting {
							SettingsFormTextFieldView(
								title: "MultitouchShiftThresholdMm",
								value: self.$viewModel.multitouchShiftThresholdMm
							)
						}
					}
				}
				.padding(.horizontal, 16)
				.padding(.top, 8)
				.background(Color(UIColor.systemGroupedBackground))
			}
			.background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
			.navigationTitle("MultiTouch settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					self.closeButton()
				}
			}
		}
	}

	private func multiTouchSwitch() -> some View {
		VStack(alignment: .leading) {
			Toggle(isOn: self.$viewModel.multiTouchEnabled, label: {
				makeGestureSettingTitle("MultiTouch enable")
			})
			.toggleStyle(SwitchToggleStyle(tint: .accentColor))
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
