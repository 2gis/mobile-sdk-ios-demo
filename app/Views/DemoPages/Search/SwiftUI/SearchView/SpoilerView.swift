import SwiftUI

struct SpoilerView<Content: View>: View {
	@State private var isExpanded = false
	let title: String
	let content: () -> Content

	var body: some View {
		VStack(alignment: .leading) {
			Button(action: {
				self.isExpanded.toggle()
			}) {
				HStack {
					Text(title)
					.font(.headline)
					Spacer()
					Image(systemName: self.isExpanded ? "chevron.up" : "chevron.down")
				}
				.foregroundColor(.primary)
			}
			.padding()
			if isExpanded {
				self.content()
				.padding([.bottom, .leading, .trailing])
			}
		}
		.overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.secondary, lineWidth: 1))
	}
}
