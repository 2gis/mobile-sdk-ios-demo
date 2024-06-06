import SwiftUI

struct PaddingRectView: View {
	@Binding var padding: PaddingRect
	var color: Color
	private let scaleValue: CGFloat = 3

	var body: some View {
		GeometryReader { geometry in
			let width = geometry.size.width - padding.left / scaleValue - padding.right / scaleValue
			let height = geometry.size.height - padding.top / scaleValue - padding.bottom / scaleValue
			let origin = CGPoint(x: padding.left / scaleValue, y: padding.top / scaleValue)
			let center = CGPoint(x: origin.x + width / 2, y: origin.y + height / 2)
			Path { path in
				path.addRect(CGRect(origin: origin, size: CGSize(width: width, height: height)))
			}
			.stroke(lineWidth: 2)
			.foregroundColor(color)
			.overlay(
				Circle()
				.stroke(color, lineWidth: 2)
				.frame(width: 7, height: 7)
				.position(center)
			)
		}
	}
}

