import SwiftUI

struct SearchResultItemView: View {
	private let viewModel: SearchResultItemViewModel

	init(viewModel: SearchResultItemViewModel) {
		self.viewModel = viewModel
	}

    var body: some View {
        VStack(alignment: .leading) {
			Text(self.viewModel.title)
			.font(.headline)
			Text(self.viewModel.subtitle)
			.font(.subheadline)
			self.viewModel.address.map(Text.init)?
			.font(.caption)
		}
    }
}
