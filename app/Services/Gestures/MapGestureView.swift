import UIKit
import DGis

/// Слой обработки жестов по умолчанию. Именно этот слой используется с MapView
/// (см. MapView.gestureView), если вручную не установить другой объект.
final class MapGestureView: UIView, IMapGestureView {
	private(set) var doubleTapGestureRecognizer: UITapGestureRecognizer?
	private(set) var panGestureRecognizer: UIPanGestureRecognizer?
	private(set) var twoFingerPanGestureRecognizer: UIPanGestureRecognizer?
	private(set) var rotationGestureRecognizer: UIRotationGestureRecognizer?
	private(set) var pinchGestureRecognizer: UIPinchGestureRecognizer?
	private(set) var twoFingerTapGestureRecognizer: UITapGestureRecognizer?
	private(set) var doubleTapAndPanGestureRecognizer: (UIGestureRecognizer & IDoubleTapAndPanGestureRecognizer)?

	var controller: IMapGestureInputController?

	private let grDelegate = DefaultMapGestureRecognizerDelegate()

	override init(frame: CGRect) {
		super.init(frame: frame)
		self.setupGestureRecognizers()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		self.setupGestureRecognizers()
	}

	private func setupGestureRecognizers() {
		self.isMultipleTouchEnabled = true

		let panGR = UIPanGestureRecognizer(target: self, action: #selector(self.pan))
		panGR.maximumNumberOfTouches = 1
		panGR.delegate = self.grDelegate
		addGestureRecognizer(panGR)
		self.panGestureRecognizer = panGR

		// Наклон карты.
		let twoFingerPanGR = UIPanGestureRecognizer(target: self, action: #selector(self.twoFingerPan))
		twoFingerPanGR.minimumNumberOfTouches = 2
		twoFingerPanGR.maximumNumberOfTouches = 2
		twoFingerPanGR.delegate = self.grDelegate
		self.addGestureRecognizer(twoFingerPanGR)
		self.twoFingerPanGestureRecognizer = twoFingerPanGR

		let rotationGR = UIRotationGestureRecognizer(target: self, action: #selector(self.rotate))
		rotationGR.delegate = self.grDelegate
		self.addGestureRecognizer(rotationGR)
		self.rotationGestureRecognizer = rotationGR

		let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch))
		pinchGR.delegate = self.grDelegate
		self.addGestureRecognizer(pinchGR)
		self.pinchGestureRecognizer = pinchGR

		let doubleTapGR = UITapGestureRecognizer(target: self, action: #selector(self.doubleTap))
		doubleTapGR.numberOfTapsRequired = 2
		doubleTapGR.numberOfTouchesRequired = 1
		doubleTapGR.delegate = self.grDelegate
		self.addGestureRecognizer(doubleTapGR)
		self.doubleTapGestureRecognizer = doubleTapGR

		let twoFingerTapGR = UITapGestureRecognizer(target: self, action: #selector(self.twoFingerTap))
		twoFingerTapGR.numberOfTapsRequired = 1
		twoFingerTapGR.numberOfTouchesRequired = 2
		self.addGestureRecognizer(twoFingerTapGR)
		self.twoFingerTapGestureRecognizer = twoFingerTapGR

		let doubleTapAndPanGR = DoubleTapAndPanGestureRecognizer(target: self, action: #selector(self.doubleTapAndPan))
		doubleTapAndPanGR.delegate = self.grDelegate
		self.addGestureRecognizer(doubleTapAndPanGR)
		self.doubleTapAndPanGestureRecognizer = doubleTapAndPanGR

		// Нужно чтобы тап отработал если не было жестов pan, rotate, pinch.
		twoFingerTapGR.require(toFail: panGR)
		twoFingerTapGR.require(toFail: rotationGR)
		twoFingerTapGR.require(toFail: pinchGR)

		// При частом таскании может случайно отработать doubleTap, мы этого не хотим.
		doubleTapGR.require(toFail: panGR)

		// Когда зумим doubleTapAndPan жестом, карту таскать не нужно.
		panGR.require(toFail: doubleTapAndPanGR)
	}
}

private extension MapGestureView {
	@objc func doubleTap(_ doubleTapGestureRecognizer: UITapGestureRecognizer) {
		let event: IMapGestureEvent = MapGestureEvent(
			state: doubleTapGestureRecognizer.state,
			location: doubleTapGestureRecognizer.location(in: self),
			coordinateSpace: self
		)

		self.controller?.didDoubleTap(with: event)
	}

	@objc func twoFingerTap(_ twoFingerTapGestureRecognizer: UITapGestureRecognizer) {
		let event: IMapGestureEvent = MapGestureEvent(
			state: twoFingerTapGestureRecognizer.state,
			location: twoFingerTapGestureRecognizer.location(in: self),
			coordinateSpace: self
		)

		self.controller?.didTwoFingerTap(with: event)
	}

	@objc func pinch(_ pinchGestureRecognizer: UIPinchGestureRecognizer) {
		let event: IMapGesturePinchEvent = MapGesturePinchEvent(
			state: pinchGestureRecognizer.state,
			location: pinchGestureRecognizer.location(in: self),
			scale: pinchGestureRecognizer.scale,
			coordinateSpace: self
		)

		self.controller?.didPinch(with: event)

		switch pinchGestureRecognizer.state {
			case .changed:
				pinchGestureRecognizer.scale = 1;
			default:
				break
		}
	}

	@objc func rotate(_ rotationGestureRecognizer: UIRotationGestureRecognizer) {
		let event: IMapGestureRotationEvent = MapGestureRotationEvent(
			state: rotationGestureRecognizer.state,
			location: rotationGestureRecognizer.location(in: self),
			rotation: rotationGestureRecognizer.rotation,
			coordinateSpace: self
		)

		self.controller?.didRotate(with: event)

		switch rotationGestureRecognizer.state {
			case .changed:
				rotationGestureRecognizer.rotation = 0.0;
			default:
				break
		}
	}

	@objc func pan(_ panGestureRecognizer: UIPanGestureRecognizer) {
		let event: IMapGesturePanEvent = MapGesturePanEvent(
			state: panGestureRecognizer.state,
			location: panGestureRecognizer.location(in: self),
			translation: panGestureRecognizer.translation(in: self),
			coordinateSpace: self
		)

		self.controller?.didPan(with: event)

		switch panGestureRecognizer.state {
			case .changed:
				panGestureRecognizer.setTranslation(.zero, in: self)
			default:
				break
		}
	}

	@objc func twoFingerPan(_ panGestureRecognizer: UIPanGestureRecognizer) {
		let event: IMapGesturePanEvent = MapGesturePanEvent(
			state: panGestureRecognizer.state,
			location: panGestureRecognizer.location(in: self),
			translation: panGestureRecognizer.translation(in: self),
			coordinateSpace: self
		)

		self.controller?.didTwoFingerPan(with: event)

		switch panGestureRecognizer.state {
			case .changed:
				panGestureRecognizer.setTranslation(.zero, in: self)
			default:
				break
		}
	}

	@objc func doubleTapAndPan(_ doubleTapAndPanRecognizer: DoubleTapAndPanGestureRecognizer) {
		let event = MapGestureDoubleTapAndPanEvent(
			state: doubleTapAndPanRecognizer.state,
			location: doubleTapAndPanRecognizer.location(in: self),
			scale: doubleTapAndPanRecognizer.scale,
			coordinateSpace: self
		)
		self.controller?.didDoubleTapAndPan(with: event)

		switch doubleTapAndPanRecognizer.state {
			case .changed:
				doubleTapAndPanRecognizer.scale = 1
			default:
				break
		}
	}
}

// MARK: - UIGestureRecognizerDelegate
private final class DefaultMapGestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
	public func gestureRecognizer(
		_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
	) -> Bool {
		true
	}
}
