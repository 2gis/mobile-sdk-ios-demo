import UIKit
import DGis

final class DoubleTapAndPanGestureRecognizer: UIGestureRecognizer, IDoubleTapAndPanGestureRecognizer {
	private enum Constants {
		/// Сколько нужно провести пальцем, чтобы изменить масштаб в 2 раза.
		/// -100 значит, что нужно провести пальцем вниз на 100 pt чтобы scale увеличился в 2 раза
		static let defaultScaleDoublingTranslation: CGFloat = -100
		static let maxTouchCount = 1
		static let panThreshold: CGFloat = 10
		static let tapThreshold: CGFloat = 10
		static let secondTapDelay: TimeInterval = 0.2
		static let maxTouchOffset: CGFloat = 20

	}
	public var scale: CGFloat = 1 {
		didSet {
			self.firstMoveY = self.currentMoveY
		}
	}
	public var scaleDoublingTranslation: CGFloat = Constants.defaultScaleDoublingTranslation

	/// Координата первого касания в координатном пространстве self.view
	/// или window, если self == nil
	private var firstTapPoint: CGPoint?
	private var firstMoveY: CGFloat = 0
	private var currentMoveY: CGFloat = 0
	private var numberOfTouchesDown: Int = 0
	private var numberOfTouchesUp: Int = 0
	private weak var timer: Timer?

	public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesBegan(touches, with: event)

		guard touches.count == Constants.maxTouchCount,
			  let currentPoint = touches.first?.location(in: self.view)
		else {
			self.state = .failed
			return
		}

		if self.firstTapPoint == nil {
			self.firstTapPoint = currentPoint
		}

		self.numberOfTouchesDown += 1

		if self.numberOfTouchesDown == 2 {
			self.stopTimer()
		}

		if (self.numberOfTouchesUp > 1 || self.numberOfTouchesDown > 2) && self.state != .failed {
			self.state = .failed
			return
		}

		if self.numberOfTouchesDown > 2,
		   let firstTapPoint = self.firstTapPoint,
		   !firstTapPoint.isNear(currentPoint, maxDistance: Constants.maxTouchOffset) {
			self.state = .failed
			return
		}
	}

	public override func location(in view: UIView?) -> CGPoint {
		if let firstTapPoint = self.firstTapPoint, let myView = self.view {
			return myView.convert(firstTapPoint, to: view)
		} else {
			return super.location(in: view)
		}
	}

	public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesMoved(touches, with: event)

		guard touches.count == Constants.maxTouchCount,
			  let firstTapPoint = self.firstTapPoint,
			  let movePoint = touches.first?.location(in: self.view)
		else {
			self.state = .failed
			return
		}

		let moveDistance = movePoint.distance(firstTapPoint)

		if self.numberOfTouchesDown == 1 && moveDistance > Constants.tapThreshold {
			self.state = .failed
			return
		}

		guard self.numberOfTouchesDown == 2, self.numberOfTouchesUp == 1 else { return }

		if self.state == .possible {
			if moveDistance > Constants.panThreshold {
				self.state = .began
				self.firstMoveY = movePoint.y
				return
			}
		} else {
			self.currentMoveY = movePoint.y
			let dy = self.firstMoveY - self.currentMoveY
			if dy > 0 {
				self.scale += dy / self.scaleDoublingTranslation
			} else {
				self.scale = max(0, self.scale + dy / self.scaleDoublingTranslation)
			}
			self.state = .changed
		}
	}

	public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesEnded(touches, with: event)

		if self.numberOfTouchesDown == 1 {
			self.timer = Timer.scheduledTimer(
				timeInterval: Constants.secondTapDelay,
				target: self,
				selector: #selector(self.onTimeout),
				userInfo: nil,
				repeats: false
			)
		}

		self.numberOfTouchesUp += 1

		if self.state == .possible && self.numberOfTouchesUp > 1 {
			self.state = .failed
		} else if self.state == .began || self.state == .changed {
			self.state = .ended
		}
	}

	public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
		super.touchesCancelled(touches, with: event)
		self.state = .cancelled
	}

	@objc private func onTimeout() {
		self.state = .failed
		self.stopTimer()
	}

	private func stopTimer() {
		self.timer?.invalidate()
	}

	public override func reset() {
		super.reset()
		self.stopTimer()
		self.numberOfTouchesDown = 0
		self.numberOfTouchesUp = 0
		self.scale = 1
		self.firstTapPoint = nil
	}
}
