import SwiftUI

struct ObjectMarkerView: View {
	private enum Constants {
		static let labelOffset: CGFloat = 10
		static let labelMaxWidth: CGFloat = 200
		static let titleColor = Color(red: 0.01, green: 0.49, blue: 0.87)
		static let titleFont = Font.system(size: 18, weight: .regular)
		static let subtitleColor = Color.primary
		static let subtitleFont = Font.system(size: 15, weight: .regular)
		static let markerRadius: CGFloat = 10
		static let markerShadowOpacity: Double = 0.7
		static let backgroundColor = Color(UIColor.systemBackground)
		static let borderColor = Color(UIColor.secondarySystemBackground)
		static let borderWidth: CGFloat = 2
	}

	let title: String
	let subtitle: String

	var body: some View {
		VStack(alignment: .leading, spacing: Constants.labelOffset) {
			Text(self.title)
				.font(Constants.titleFont)
				.foregroundColor(Constants.titleColor)
			Text(self.subtitle)
				.font(Constants.subtitleFont)
				.foregroundColor(Constants.subtitleColor)
		}
		.padding(Constants.labelOffset)
		.background(Constants.backgroundColor)
		.cornerRadius(Constants.markerRadius)
		.overlay(
			RoundedRectangle(cornerRadius: Constants.markerRadius)
				.stroke(Constants.borderColor, lineWidth: Constants.borderWidth)
		)
		.fixedSize()
	}
}
