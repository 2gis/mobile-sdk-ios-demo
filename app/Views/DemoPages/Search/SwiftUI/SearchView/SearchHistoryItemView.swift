import SwiftUI

struct SearchHistoryItemView: View {
	private let viewModel: SearchHistoryItemViewModel

	init(viewModel: SearchHistoryItemViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		VStack(alignment: .leading) {
			HStack(alignment: .firstTextBaseline) {
				Text(self.viewModel.title)
					.font(.headline)
					.foregroundColor(.primary)
					.multilineTextAlignment(.leading)

				self.viewModel.icon
			}
			Text(self.viewModel.subtitle)
				.font(.subheadline)
				.foregroundColor(.secondary)
		}
	}
}
