import SwiftUI

struct NavigatorVoicesSettingsView: View {
	@Binding private var isPresented: Bool
	@ObservedObject private var viewModel: NavigatorSettingsViewModel

	init(viewModel: NavigatorSettingsViewModel, isPresented: Binding<Bool>) {
		self.viewModel = viewModel
		self._isPresented = isPresented
	}

	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Installed Voices")) {
					ForEach(self.viewModel.voiceRows.filter { $0.isReadyToUse }) { rowVM in
						Button(action: {
							self.viewModel.select(rowVM)
						}, label: {
							VoiceRow(viewModel: rowVM)
						})
					}
				}
				Section(header: Text("Available Voices")) {
					ForEach(self.viewModel.voiceRows.filter { !$0.isReadyToUse }) { rowVM in
						Button(action: {
							self.viewModel.select(rowVM)
						}, label: {
							VoiceRow(viewModel: rowVM)
						})
					}
				}
			}
			.navigationBarTitle(Text("Voice packages"), displayMode: .inline)
			.navigationBarItems(trailing: Button("Close", action: { self.isPresented = false }))
		}
	}
}
