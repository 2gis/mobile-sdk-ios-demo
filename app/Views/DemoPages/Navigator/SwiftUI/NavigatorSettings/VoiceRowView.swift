import SwiftUI

struct VoiceRow: View {
	@ObservedObject private var viewModel: VoiceRowViewModel

	init(viewModel: VoiceRowViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		if self.viewModel.isReadyToUse {
			HStack {
				if self.viewModel.isSelected {
					Image(systemName: "checkmark")
					.foregroundColor(.green)
					.aspectRatio(contentMode: .fit)
					.frame(width: 44, height: 44)
				} else {
					Color.clear
					.aspectRatio(contentMode: .fit)
					.frame(width: 44, height: 44)
				}
				VStack(alignment: .leading) {
					Text(self.viewModel.name)
					.foregroundColor(.primaryTitle)
					Text(self.viewModel.status.description)
					.fontWeight(.light)
					.foregroundColor(.secondary)
				}
				Spacer()
				if self.viewModel.downloadAvailable {
					self.installVoiceButton()
				}
				if self.viewModel.uninstallAvailable {
					self.uninstallVoiceButton()
				}
			}
		} else {
			HStack {
				self.playWelcomeButton()
				VStack(alignment: .leading) {
					Text(self.viewModel.name)
					.foregroundColor(.primaryTitle)
					Text(self.viewModel.status.description)
					.fontWeight(.light)
					.foregroundColor(.secondary)
				}
				Spacer()
				if self.viewModel.downloadAvailable {
					self.installVoiceButton()
				}
			}
		}
	}
	
	private func playWelcomeButton() -> some View {
		Button(action: {
			self.viewModel.play()
		}, label: {
			Image(systemName: "play.fill")
			.foregroundColor(.secondary)
			.aspectRatio(contentMode: .fit)
			.frame(minWidth: 44, minHeight: 44)
		})
	}

	private func installVoiceButton() -> some View {
		Image(systemName: "square.and.arrow.down")
		.aspectRatio(contentMode: .fit)
		.frame(minWidth: 44, minHeight: 44)
	}

	private func uninstallVoiceButton() -> some View {
		Button(action: {
			self.viewModel.isUninstallRequestShown = true
		}) {
			Image(systemName: "xmark")
			.foregroundColor(.secondary)
			.aspectRatio(contentMode: .fit)
			.frame(minWidth: 44, minHeight: 44)
		}
		.actionSheet(isPresented: self.$viewModel.isUninstallRequestShown, content: {
			ActionSheet(
				title: Text("Remove voice package «\(self.viewModel.name)»?"),
				buttons: [
					.destructive(Text("Remove"), action: { self.viewModel.uninstall() }),
					.cancel()
				]
			)
		})
	}
}
