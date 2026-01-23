import SwiftUI

func sectionGestureSetting(@ViewBuilder content: () -> some View) -> some View {
	VStack(alignment: .leading, spacing: 0) {
		content()
	}
	.padding(.vertical, 12)
	.padding(.horizontal, 16)
	.background(
		RoundedRectangle(cornerRadius: 12, style: .continuous)
			.fill(Color(UIColor.secondarySystemGroupedBackground))
	)
	.overlay(
		RoundedRectangle(cornerRadius: 12, style: .continuous)
			.stroke(Color(UIColor.separator).opacity(0.4), lineWidth: 0.5)
	)
}

func makeGestureSettingTitle(_ text: String) -> Text {
	Text(text)
		.font(.system(size: 20))
		.fontWeight(.bold)
		.foregroundColor(.primaryTitle)
}
