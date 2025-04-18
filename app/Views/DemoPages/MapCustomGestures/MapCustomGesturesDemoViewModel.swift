import DGis
import SwiftUI

final class MapCustomGesturesDemoViewModel: ObservableObject {
	enum ShiftDirection {
		case left, right, top, down

		var screenShift: ScreenShift {
			switch self {
			case .left:
				return .init(dx: 100, dy: 0)
			case .right:
				return .init(dx: -100, dy: 0)
			case .top:
				return .init(dx: 0, dy: 100)
			case .down:
				return .init(dx: 0, dy: -100)
			}
		}
	}

	enum RotationDirection {
		case clockwise, counterClockwise

		var bearingDelta: Bearing {
			switch self {
			case .clockwise:
				return .init(floatLiteral: 10)
			case .counterClockwise:
				return .init(floatLiteral: -10)
			}
		}
	}

	enum TiltDirection {
		case up, down

		var tiltDelta: Float {
			switch self {
			case .up:
				return 5
			case .down:
				return -5
			}
		}
	}

	enum ScaleDirection {
		case zoomIn, zoomOut

		var zoomDelta: Float {
			switch self {
			case .zoomIn:
				return 0.3
			case .zoomOut:
				return -0.3
			}
		}
	}

	private let map: Map
	private let mapEventProcessor: DemoMapEventProcessor

	private var timestamp: TimeInterval {
		Date().timeIntervalSince1970
	}

	private var centerPoint: ScreenPoint {
		.init(
			x: Float(UIScreen.main.bounds.width * UIScreen.main.scale / 2),
			y: Float(UIScreen.main.bounds.height * UIScreen.main.scale / 2)
		)
	}

	init(
		map: Map,
		mapEventProcessor: DemoMapEventProcessor
	) {
		self.map = map
		self.mapEventProcessor = mapEventProcessor
	}

	func mapRotationEvent(_ rotationDirection: RotationDirection) {
		self.processEvent(
			DirectMapRotationEvent(
				bearingDelta: rotationDirection.bearingDelta,
				timestamp: self.timestamp,
				rotationCenter: self.centerPoint
			)
		)
	}

	func mapShiftEvent(_ shiftDirection: ShiftDirection) {
		self.processEvent(
			DirectMapShiftEvent(
				screenShift: shiftDirection.screenShift,
				shiftedPoint: self.centerPoint,
				timestamp: self.timestamp
			)
		)
	}

	func mapTiltEvent(_ tiltDirection: TiltDirection) {
		self.processEvent(
			DirectMapTiltEvent(
				delta: tiltDirection.tiltDelta,
				timestamp: self.timestamp
			)
		)
	}

	func mapScalingEvent(_ scaleDirection: ScaleDirection) {
		self.processEvent(
			DirectMapScalingEvent(
				zoomDelta: scaleDirection.zoomDelta,
				timestamp: self.timestamp,
				scalingCenter: self.centerPoint
			)
		)
	}

	private func processEvent(_ event: Event) {
		self.mapEventProcessor.process(event: DirectMapControlBeginEvent())
		self.mapEventProcessor.process(event: event)
		self.mapEventProcessor.process(event: DirectMapControlEndEvent(timestamp: self.timestamp))
	}
}
