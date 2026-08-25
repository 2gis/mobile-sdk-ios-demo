import Combine
import DGis
import SwiftUI

@MainActor
final class MapCustomGesturesDemoViewModel: ObservableObject, @unchecked Sendable {
	enum ShiftDirection {
		case left, right, top, down

		var screenShift: ScreenShift {
			switch self {
			case .left:
				.init(dx: 100, dy: 0)
			case .right:
				.init(dx: -100, dy: 0)
			case .top:
				.init(dx: 0, dy: 100)
			case .down:
				.init(dx: 0, dy: -100)
			@unknown default:
				fatalError("Unknown type: \(self)")
			}
		}
	}

	enum RotationDirection {
		case clockwise, counterClockwise

		var bearingDelta: Bearing {
			switch self {
			case .clockwise:
				.init(floatLiteral: 10)
			case .counterClockwise:
				.init(floatLiteral: -10)
			@unknown default:
				fatalError("Unknown type: \(self)")
			}
		}
	}

	enum TiltDirection {
		case up, down

		var tiltDelta: Float {
			switch self {
			case .up:
				5
			case .down:
				-5
			@unknown default:
				fatalError("Unknown type: \(self)")
			}
		}
	}

	enum ScaleDirection {
		case zoomIn, zoomOut

		var zoomDelta: Float {
			switch self {
			case .zoomIn:
				0.3
			case .zoomOut:
				-0.3
			@unknown default:
				fatalError("Unknown type: \(self)")
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
