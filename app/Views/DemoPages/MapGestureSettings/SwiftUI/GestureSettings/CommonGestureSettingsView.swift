import SwiftUI

struct CommonGestureSettingsView: View {
	@ObservedObject private var viewModel: CommonGestureSettingsViewModel
	@Binding var isPresented: Bool

	init(
		viewModel: CommonGestureSettingsViewModel,
		isPresented: Binding<Bool>
	) {
		self.viewModel = viewModel
		self._isPresented = isPresented
	}

	var body: some View {
		NavigationView {
			ScrollView {
				LazyVStack(alignment: .leading, spacing: 12) {
					sectionGestureSetting {
						SettingsFormTextFieldView(
							title: "InterGestureTimeout",
							value: self.$viewModel.interGestureTimeout
						)
					}
				}
				.padding(.horizontal, 16)
				.padding(.top, 8)
				.background(Color(UIColor.systemGroupedBackground))
			}
			.background(Color(UIColor.systemGroupedBackground).ignoresSafeArea())
			.navigationTitle("CommonGesture settings")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					self.closeButton()
				}
			}
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
