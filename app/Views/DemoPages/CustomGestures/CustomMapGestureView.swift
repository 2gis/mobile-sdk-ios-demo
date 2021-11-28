import UIKit
import DGis

class CustomMapGestureView: UIView, IMapGestureView {
	private(set) var panGestureRecognizer: UIPanGestureRecognizer?
	private(set) var pinchGestureRecognizer: UIPinchGestureRecognizer?

	var rotationGestureRecognizer: UIRotationGestureRecognizer? {
		self.defaultMapGestureView?.rotationGestureRecognizer
	}

	private let mapEventProcessor: IMapEventProcessor
	private let mapCoordinateSpace: IMapCoordinateSpace
	private let defaultMapGestureView: IMapGestureView?

	init(
		map: Map,
		mapEventProcessor: IMapEventProcessor,
		mapCoordinateSpace: IMapCoordinateSpace
	) {
		self.mapEventProcessor = mapEventProcessor
		self.mapCoordinateSpace = mapCoordinateSpace
		let gestureViewFactory = MapOptions.default.gestureViewFactory
		self.defaultMapGestureView = gestureViewFactory?.makeGestureView(
			map: map,
			eventProcessor: mapEventProcessor,
			coordinateSpace: mapCoordinateSpace
		)
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

		self.rotationGestureRecognizer.map(self.addGestureRecognizer)
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

				// Существует разница между масштабом (zoom) и множителем (scale).
				// Их взаимоотношение подчиняется формуле: scale = C*exp(2, zoom).
				// Для передачи события необходимо именно изменение масштаба,
				// выражающегося через логарифм от изменения множителя.
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
