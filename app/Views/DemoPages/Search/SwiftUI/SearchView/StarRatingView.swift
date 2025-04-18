import SwiftUI

struct StarRatingView: View {
	private enum Constants {
		static let starSize: CGFloat = 14
		static let maxRating: Int = 5
	}

	let rating: Float
	private let colorFilled: Color = .orange
	private let colorUnfilled: Color = .gray

	var body: some View {
		HStack(spacing: 5) {
			ForEach(0..<Constants.maxRating, id: \.self) { index in
				self.starView(for: index, rating: rating)
			}
		}
	}

	private func starView(for index: Int, rating: Float) -> some View {
		let fillValue = min(max(rating - Float(index), 0), 1)
		return ZStack {
			Image(systemName: "star.fill")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: Constants.starSize, height: Constants.starSize)
			.foregroundColor(colorUnfilled)
			if fillValue > 0 {
				Image(systemName: "star.fill")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: Constants.starSize, height: Constants.starSize)
				.foregroundColor(colorFilled)
				.mask(
					Rectangle()
					.size(width: CGFloat(fillValue) * Constants.starSize, height: Constants.starSize)
				)
			}
		}
	}
}
