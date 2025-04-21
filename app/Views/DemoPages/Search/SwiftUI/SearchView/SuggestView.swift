import SwiftUI

struct SuggestView: View {
	let viewModel: SuggestViewModel

	var body: some View {
		VStack(alignment: .leading) {
			HStack(alignment: .firstTextBaseline) {
				MarkedUpTextView(
					markup: self.viewModel.title,
					normalFont: Font.callout,
					matchFont: Font.callout.weight(.bold)
				)
				self.viewModel.icon
			}
			MarkedUpTextView(
				markup: self.viewModel.subtitle,
				normalFont: Font.caption,
				matchFont: Font.caption.weight(.bold),
				distance: self.viewModel.object?.distanceToObject
			)
		}
	}
}
