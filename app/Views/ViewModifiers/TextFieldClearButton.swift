import SwiftUI

struct TextFieldClearButton: ViewModifier {
	@Binding var text: String

	init(text: Binding<String>) {
		self._text = text
	}

	func body(content: Content) -> some View {
		HStack {
			content
			Spacer()
			Image(systemName: "multiply.circle.fill")
				.foregroundColor(.secondary)
				.opacity(text == "" ? 0 : 1)
				.onTapGesture {
					self.text = ""
				}
		}
	}
}
