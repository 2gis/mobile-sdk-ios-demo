import SwiftUI

struct StyleRow: View {
	@ObservedObject var viewModel: SettingsViewModel
	var style: URL
	@State private var showAlert = false

	private var isSelected: Bool {
		return self.style == self.viewModel.selectedStyle
	}

	var body: some View {
		HStack {
			Text(self.style.lastPathComponent)
			Spacer()
		}
		.padding(8)
		.background(
			RoundedRectangle(cornerRadius: 10)
			.fill(self.isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
		)
		.foregroundColor(self.isSelected ? Color.white : Color.primary)
		.contentShape(Rectangle())
		.onTapGesture {
			self.viewModel.saveStyleURL(style)
		}
		.onLongPressGesture(
			minimumDuration: 1.0,
			maximumDistance: 50,
			perform: {
				if self.style != self.viewModel.getDefaultStyleURL() {
					self.showAlert = true
				}
			}
		)
		.alert(isPresented: self.$showAlert) {
			Alert(
				title: Text("Delete style"),
				message: Text("Are you sure you want to delete \(self.style.lastPathComponent)?"),
				primaryButton: .destructive(Text("Delete")) {
					self.viewModel.deleteStyle(self.style)
					if self.isSelected {
						self.viewModel.saveStyleURL(nil)
					}
				},
				secondaryButton: .cancel()
			)
		}
	}
}
