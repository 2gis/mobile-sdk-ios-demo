import UIKit
import DGis

final class MapGestureInputController {
	private let processor: IMapEventProcessor
	private let coordinateSpace: IMapCoordinateSpace

	init(
		processor: IMapEventProcessor,
		coordinateSpace: IMapCoordinateSpace
	) {
		self.processor = processor
		self.coordinateSpace = coordinateSpace
	}
}

extension MapGestureInputController: IMapGestureInputController {
	func didPan(with event: IMapGesturePanEvent) {
		switch event.state {
			case .began:
				self.processor.beginShifting()

			case .changed:
				let location = event.location(in: self.coordinateSpace)
				let translation = event.translation
				let from = CGPoint(
					x: location.x - translation.x,
					y: location.y - translation.y
				)

				if from != location {
					let toPixels = self.coordinateSpace.toPixels
					let from = from.applying(toPixels)
					let location = location.applying(toPixels)
					let vector = CGVector(
						dx: location.x - from.x,
						dy: location.y - from.y
					)
					self.processor.shift(from: from, by: vector)
				}

			case .ended:
				self.processor.endShifting()
			case .failed, .cancelled:
				self.processor.cancel()
			default:
				break
		}
	}

	func didTwoFingerPan(with event: IMapGesturePanEvent) {
		switch event.state {
			case .began:
				self.processor.beginTilting()
			case .changed:
				let deltaY = CGFloat.pi*event.translation.y
				let deltaRad = deltaY / self.coordinateSpace.bounds.height
				self.processor.updateTilt(delta: deltaRad)
			case .ended:
				self.processor.endTilting()
			case .failed, .cancelled:
				self.processor.cancel()
			default:
				break
		}
	}

	func didDoubleTapAndPan(with event: IMapGestureDoubleTapAndPanEvent) {
		switch event.state {
			case .began:
				self.processor.beginShifting()
			case .changed:
				let location = event.location(in: self.coordinateSpace)
					.applying(self.coordinateSpace.toPixels)
				self.processor.updateScale(event.scale, location: location)
			case .failed, .ended, .cancelled:
				self.processor.endScaling()
			default:
				break
		}
	}

	func didRotate(with event: IMapGestureRotationEvent) {
		switch event.state {
			case .began:
				self.processor.beginRotating()
			case .changed:
				let centerPoint = event.location(in: self.coordinateSpace)
					.applying(self.coordinateSpace.toPixels)
				let rotation = event.rotation
				self.processor.updateRotation(
					atCenter: centerPoint,
					rotation: rotation
				)
			case .failed, .ended, .cancelled:
				self.processor.endRotating()
			default:
				break
		}
	}

	func didPinch(with event: IMapGesturePinchEvent) {
		switch event.state {
			case .began:
				self.processor.beginScaling()
			case .changed:
				let scale = event.scale
				let location = event.location(in: self.coordinateSpace)
					.applying(self.coordinateSpace.toPixels)
				self.processor.updateScale(scale, location: location)
			case .ended:
				self.processor.endScaling()
			case .failed, .cancelled:
				self.processor.cancel()
			default:
				break
		}
	}

	func didDoubleTap(with event: IMapGestureEvent) {
		if event.state == .ended {
			self.processor.startScaling(inDirection: .zoomIn)
			self.processor.stopScaling()
		}
	}

	func didTwoFingerTap(with event: IMapGestureEvent) {
		if event.state == .ended {
			self.processor.startScaling(inDirection: .zoomOut)
			self.processor.stopScaling()
		}
	}
}
