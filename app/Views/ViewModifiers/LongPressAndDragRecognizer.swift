import SwiftUI

enum LongPressAndDragRecognizerState: Equatable {
	case inactive
	case started(location: CGPoint)
	case changed(location: CGPoint)
}

private enum LongPressAndDragRecognizerConstants {
	static let defaultLongPressDuration: TimeInterval = 0.5
	static let minimumDistance: CGFloat = 0.5
	static let defaultCoordinateSpace: CoordinateSpace = .local
}

struct LongPressAndDragRecognizer: ViewModifier {
	private let coordinateSpace: CoordinateSpace
	private let longPressDuration: TimeInterval
	private let minimumDistance: CGFloat
	@GestureState private var gestureState: LongPressAndDragRecognizerState = .inactive
	private let stateReceiver: (LongPressAndDragRecognizerState) -> Void

	init(
		longPressDuration: TimeInterval = LongPressAndDragRecognizerConstants.defaultLongPressDuration,
		coordinateSpace: CoordinateSpace = LongPressAndDragRecognizerConstants.defaultCoordinateSpace,
		minimumDistance: CGFloat = LongPressAndDragRecognizerConstants.minimumDistance,
		stateReceiver: @escaping (LongPressAndDragRecognizerState) -> Void
	) {
		self.longPressDuration = longPressDuration
		self.coordinateSpace = coordinateSpace
		self.minimumDistance = minimumDistance
		self.stateReceiver = stateReceiver
	}

	func body(content: Content) -> some View {
		content
		.gesture(
			self.makeLongPressDragGesture()
			.onChanged { value in
				self.handleStateChange()
			}
			.onEnded { value in
				self.handleStateChange()
			}
		)
	}

	private func makeLongPressDragGesture() -> GestureStateGesture<SequenceGesture<LongPressGesture, DragGesture>, LongPressAndDragRecognizerState> {
		LongPressGesture(minimumDuration: self.longPressDuration)
		.sequenced(before: DragGesture(minimumDistance: 0, coordinateSpace: self.coordinateSpace))
		.updating(self.$gestureState) { value, state, transaction in
			switch value {
				case .first(true):
					state = .inactive
				case .second(true, let drag):
					if let dragLocation = drag?.location {
						switch state {
							case .inactive:
								state = .started(location: dragLocation)
							case .started:
								state = .changed(location: dragLocation)
							case .changed(let location):
								let distance = abs(location.distance(to: dragLocation))
								if distance >= self.minimumDistance {
									state = .changed(location: dragLocation)
								}
						}
					}
				default:
					state = .inactive
			}
		}
	}

	private func handleStateChange() {
		self.stateReceiver(self.gestureState)
	}
}

extension View {
	func longPressAndDragRecognizer(
		longPressDuration: TimeInterval = LongPressAndDragRecognizerConstants.defaultLongPressDuration,
		coordinateSpace: CoordinateSpace = LongPressAndDragRecognizerConstants.defaultCoordinateSpace,
		minimumDistance: CGFloat = LongPressAndDragRecognizerConstants.minimumDistance,
		_ stateReceiver: @escaping (LongPressAndDragRecognizerState) -> Void
	) -> some View {
		self.modifier(
			LongPressAndDragRecognizer(
				longPressDuration: longPressDuration,
				coordinateSpace: coordinateSpace,
				minimumDistance: minimumDistance,
				stateReceiver: stateReceiver
			)
		)
	}
}

private extension CGPoint {
	func distance(to point: CGPoint) -> CGFloat {
		sqrt(pow(point.x - self.x, 2) + pow(point.y - self.y, 2))
	}
}
