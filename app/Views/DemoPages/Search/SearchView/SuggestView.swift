import SwiftUI

struct SuggestView: View {
	let viewModel: SuggestViewModel

	var body: some View {
		HStack(alignment: .firstTextBaseline) {
			VStack(alignment: .leading) {
				Text(self.viewModel.title)
					.font(Font.callout)
				if let subtitle = self.viewModel.subtitle {
					Text(subtitle)
						.font(Font.caption)
				}
			}
			self.viewModel.icon
		}
	}
}
