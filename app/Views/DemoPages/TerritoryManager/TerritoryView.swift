import SwiftUI

struct TerritoryView: View {
	@ObservedObject private var viewModel: TerritoryViewModel

	init(viewModel: TerritoryViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
			HStack {
				VStack(alignment: .leading) {
					Text(self.viewModel.name)

					Text(self.viewModel.status.description)
					.fontWeight(.light)
					.foregroundColor(.gray)
				}
				Spacer()
				if self.viewModel.downloadAvailable {
					self.installVoiceButton()
				}
				if self.viewModel.uninstallAvailable {
					self.uninstallVoiceButton()
				}
			}
		}

		private func installVoiceButton() -> some View {
			Button(action: {
				self.viewModel.install()
			}, label: {
				Image(systemName: "icloud.and.arrow.down.fill")
				.aspectRatio(contentMode: .fit)
				.frame(minWidth: 44, minHeight: 44)
			})
		}

		private func uninstallVoiceButton() -> some View {
			Button(action: {
				self.viewModel.isUninstallRequestShown = true
			}, label: {
				Image(systemName: "trash.fill")
				.aspectRatio(contentMode: .fit)
				.frame(minWidth: 44, minHeight: 44)
			})
			.actionSheet(isPresented: self.$viewModel.isUninstallRequestShown, content: {
				ActionSheet(
					title: Text("Удалить \"\(self.viewModel.name)\"?"),
					buttons: [
						.destructive(Text("Удалить"), action: { self.viewModel.uninstall() }),
						.cancel()
					]
				)
			})
		}
}
