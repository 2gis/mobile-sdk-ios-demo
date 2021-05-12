import SwiftUI

struct TouchUpRecognizer: ViewModifier {
	let coordinateSpace: CoordinateSpace
	let gestureHandler: (CGPoint) -> Void

	func body(content: Content) -> some View {
		content.simultaneousGesture(self.drag)
	}

	private var drag: some Gesture {
		DragGesture(
			minimumDistance: 0,
			coordinateSpace: coordinateSpace
		)
		.onEnded { info in
			if abs(info.translation.width) < 10, abs(info.translation.height) < 10 {
				self.gestureHandler(info.startLocation)
			}
		}
	}
}

extension View {
	func touchUpRecognizer(
		coordinateSpace: CoordinateSpace,
		handler: @escaping (CGPoint) -> Void
	) -> some View {
		self.modifier(
			TouchUpRecognizer(coordinateSpace: coordinateSpace, gestureHandler: handler)
		)
	}
}
