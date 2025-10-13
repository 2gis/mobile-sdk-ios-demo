import Foundation
import func QuartzCore.CACurrentMediaTime
import class QuartzCore.CADisplayLink

@MainActor
private let defaultFunction: @Sendable (CFTimeInterval, CFTimeInterval) -> Double = {
	time, duration in guard duration > 0 else { return 1 }
	return time / duration
}

/// Удобная реализация для анимации.
@MainActor
class ValueAnimator {
	private let from: Double
	private let to: Double

	private var duration: CFTimeInterval = 0
	private var startTime: CFTimeInterval?
	private var displayLink: CADisplayLink?
	private let animationCurveFunction: @Sendable (CFTimeInterval, CFTimeInterval) -> Double
	private var valueUpdater: (Double) -> Void

	init(
		from: Double,
		to: Double,
		duration: TimeInterval,
		animationCurveFunction: @escaping @Sendable (TimeInterval, TimeInterval) -> Double = defaultFunction,
		valueUpdater: @escaping @Sendable (Double) -> Void
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
	@MainActor
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

	@MainActor
	private func updateValue(startTime: CFTimeInterval) {
		self.valueUpdater(self.from + (self.to - self.from) * self.animationCurveFunction(startTime, self.duration))
	}

	func cancel() {
		self.displayLink?.isPaused = true
		self.displayLink?.invalidate()
		self.displayLink = nil
	}
}
