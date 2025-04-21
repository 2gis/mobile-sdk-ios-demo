import UIKit
import DGis

class CustomMapGestureView: UIView, IMapGestureView {
	private(set) var panGestureRecognizer: UIPanGestureRecognizer?
	private(set) var pinchGestureRecognizer: UIPinchGestureRecognizer?

	private let mapEventProcessor: IMapEventProcessor
	private let mapCoordinateSpace: IMapCoordinateSpace

	init(mapEventProcessor: IMapEventProcessor, mapCoordinateSpace: IMapCoordinateSpace) {
		self.mapEventProcessor = mapEventProcessor
		self.mapCoordinateSpace = mapCoordinateSpace
		super.init(frame: .zero)

		self.setupGestureRecognizers()
	}

	required init?(coder: NSCoder) {
		fatalError("Use init(mapEventProcessor:)")
	}

	private func setupGestureRecognizers() {
		self.isMultipleTouchEnabled = true

		let panGR = UIPanGestureRecognizer(target: self, action: #selector(self.pan))
		panGR.delegate = self
		self.addGestureRecognizer(panGR)
		self.panGestureRecognizer = panGR

		let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch))
		pinchGR.delegate = self
		self.addGestureRecognizer(pinchGR)
		self.pinchGestureRecognizer = pinchGR
	}

	@objc func pinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
		switch pinchGestureRecognizer.state {
			case .began:
				self.mapEventProcessor.process(event: DirectMapControlBeginEvent())
			case .changed:
				let scalingCenter = self.center
				let scaleDelta = pinchGestureRecognizer.scale
				let convertedScalingCenter = self.convert(scalingCenter, to: self.mapCoordinateSpace)
					.applying(self.mapCoordinateSpace.toPixels)

				let zoomDelta = Float(log2(scaleDelta))
				let center = ScreenPoint(convertedScalingCenter)
				let event = DirectMapScalingEvent(
					zoomDelta: zoomDelta,
					timestamp: .now(),
					scalingCenter: center
				)
				self.mapEventProcessor.process(event: event)

				pinchGestureRecognizer.scale = 1
			case .ended:
				self.mapEventProcessor.process(event: DirectMapControlEndEvent(timestamp: .now()))
			case .cancelled, .failed:
				self.mapEventProcessor.process(event: CancelEvent())
			default:
				break
		}
	}

	@objc func pan(_ panGestureRecognizer: UIPanGestureRecognizer) {
		switch panGestureRecognizer.state {
			case .began:
				self.mapEventProcessor.process(event: DirectMapControlBeginEvent())
			case .changed:
				let location = panGestureRecognizer.location(in: self)
				let translation = panGestureRecognizer.translation(in: self)
				let targetLocation = self.convert(location, to: self.mapCoordinateSpace)
				let from = CGPoint(
					x: targetLocation.x - translation.x,
					y: targetLocation.y - translation.y
				)

				if from != targetLocation {
					let toPixels = self.mapCoordinateSpace.toPixels
					let from = from.applying(toPixels)
					let location = targetLocation.applying(toPixels)
					let vector = CGVector(
						dx: location.x - from.x,
						dy: location.y - from.y
					)
					let fromPoint = ScreenPoint(from)
					let shift = ScreenShift(vector)
					let event = DirectMapShiftEvent(
						screenShift: shift,
						shiftedPoint: fromPoint,
						timestamp: .now()
					)
					self.mapEventProcessor.process(event: event)
				}
				panGestureRecognizer.setTranslation(.zero, in: self)
			case .ended:
				self.mapEventProcessor.process(event: DirectMapControlEndEvent(timestamp: .now()))
			case .cancelled, .failed:
				self.mapEventProcessor.process(event: CancelEvent())
			default:
				break
		}
	}
}

extension CustomMapGestureView: UIGestureRecognizerDelegate {
	func gestureRecognizer(
		_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
	) -> Bool {
		true
	}
}

private extension TimeInterval {
	static func now() -> TimeInterval {
		TimeInterval(CACurrentMediaTime())
	}
}
