import SwiftUI

struct SearchResultItemView: View {
	private let viewModel: SearchResultItemViewModel

	init(viewModel: SearchResultItemViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				VStack(alignment: .leading) {
					Text(self.viewModel.title)
					.font(.headline)
					.foregroundColor(.primary)
					Text(self.viewModel.subtitle)
					.font(.subheadline)
					.foregroundColor(.secondary)
				}
				Spacer()
				if self.viewModel.hasEVCharging {
					Image("svg/ev_charger_green")
				}
			}
			HStack {
				if let reviews = self.viewModel.reviews {
					StarRatingView(rating: reviews.rating)
					Text(String(format: "%.1f", reviews.rating))
					.font(.subheadline)
					.bold()
					.foregroundColor(.primary)
					Text("\(reviews.count) reviews")
					.font(.subheadline)
					.foregroundColor(.secondary)
				} else {
					Text("No reviews")
					.font(.subheadline)
					.foregroundColor(.secondary)
				}
				Spacer()
				Text(self.viewModel.distance?.description ?? "")
				.font(.subheadline)
				.foregroundColor(.secondary)
			}
			self.viewModel.address.map(Text.init)?
			.font(.caption)
		}
	}
	
	var stars: some View {
		EmptyView()
	}
}
