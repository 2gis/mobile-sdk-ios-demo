import SwiftUI

struct DetailsActionView: View {
	private let action: () -> Void
	private let primaryText: String
	private let detailsText: String?

	init(action: @escaping () -> Void, primaryText: String, detailsText: String? = nil) {
		self.action = action
		self.primaryText = primaryText
		self.detailsText = detailsText
	}

	var body: some View {
		Button(action: self.action, label: {
			VStack {
				if let detailsText = self.detailsText {
					Text(detailsText).font(.caption).foregroundColor(.gray)
				}
				Text(self.primaryText)
			}
		})
		.background(
			RoundedRectangle(cornerRadius: 6)
			.scale(1.2)
			.fill(Color.white)
		)
	}
}
