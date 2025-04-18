import class QuartzCore.CADisplayLink
import func QuartzCore.CACurrentMediaTime
import Foundation

fileprivate var defaultFunction: (CFTimeInterval, CFTimeInterval) -> (Double) = { time, duration in
	return time / duration
}

/// Удобная реализация для анимации.
class ValueAnimator {
	private let from: Double
	private let to: Double

	private var duration: CFTimeInterval = 0
	private var startTime: CFTimeInterval? = nil
	private var displayLink: CADisplayLink?
	private var animationCurveFunction: (CFTimeInterval, CFTimeInterval) -> (Double)
	private var valueUpdater: (Double) -> Void

	init (
		from: Double,
		to: Double,
		duration: TimeInterval,
		animationCurveFunction: @escaping (TimeInterval, TimeInterval) -> (Double) = defaultFunction,
		valueUpdater: @escaping (Double) -> Void
	) {
		self.from = from
		self.to = to
		self.duration = duration
		self.animationCurveFunction = animationCurveFunction
		self.valueUpdater = valueUpdater
	}

	func start() {
		self.displayLink = CADisplayLink(target: self, selector: #selector(self.update))
		self.displayLink?.add(to: .current, forMode: .default)
	}

	@objc
	private func update() {
		guard let startTime = self.startTime else {
			self.startTime = CACurrentMediaTime()
			self.updateValue(startTime: 0)
			return
		}

		var timeElapsed = CACurrentMediaTime() - startTime
		var stop = false

		if timeElapsed > self.duration {
			timeElapsed = self.duration
			stop = true
		}

		self.updateValue(startTime: timeElapsed)
		if stop {
			self.cancel()
		}
	}

	private func updateValue(startTime: CFTimeInterval) {
		self.valueUpdater(self.from + (self.to - self.from) * self.animationCurveFunction(startTime, self.duration))
	}

	func cancel() {
		self.displayLink?.isPaused = true
		self.displayLink?.invalidate()
		self.displayLink = nil
	}
}
