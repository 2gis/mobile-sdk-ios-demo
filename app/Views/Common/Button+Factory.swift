import SwiftUI

extension Button where Label == AnyView {
	static func makeCircleButton(
		iconName: String,
		iconSize: CGSize = .init(width: 40, height: 40),
		backgroundColor: Color = .white,
		shadowRadius: CGFloat = 3,
		action: @escaping () -> Void
	) -> Button {
		Button(action: action) {
			AnyView(
				Image(systemName: iconName)
				.frame(width: iconSize.width, height: iconSize.height, alignment: .center)
				.contentShape(Rectangle())
				.background(
					Circle()
					.fill(backgroundColor)
					.shadow(radius: shadowRadius)
				)
			)
		}
	}
}
