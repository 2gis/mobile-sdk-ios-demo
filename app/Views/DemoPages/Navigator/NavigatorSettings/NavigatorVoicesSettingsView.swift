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
			List(self.viewModel.voiceRows) { rowVM in
				Button(action: {
					self.viewModel.select(rowVM)
				}, label: {
					VoiceRow(viewModel: rowVM)
				})
			}
			.navigationBarTitle(Text("Голосовые пакеты"), displayMode: .inline)
			.navigationBarItems(trailing: Button("Закрыть", action: { self.isPresented = false }))
		}
	}
}
