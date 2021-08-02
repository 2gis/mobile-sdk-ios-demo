import CoreGraphics
import func UIKit.CACurrentMediaTime
import struct Foundation.TimeInterval
import DGis

extension IMapEventProcessor {
	/// Начать масштабирование карты.
	///
	/// Следом ожидается любое количество вызовов `updateScale(_:location:)`,
	/// после чего вызов `endScaling()`.
	func beginScaling() {
		self.beginDirectMapControl()
	}

	/// Изменить текущий масштаб карты на указанное приращение.
	func updateScale(_ scaleDelta: CGFloat, location: CGPoint) {
		// Существует разница между масштабом (zoom) и множителем (scale).
		// Их взаимоотношение подчиняется формуле: scale = C*exp(2, zoom).
		// Для передачи события необходимо именно изменение масштаба,
		// выражающегося через логарифм от изменения множителя.
		let zoomDelta = Float(log2(scaleDelta))
		// Передаём nil в качестве центральной точки, чтобы центрироваться
		// на точке местоположения.
		let event = DirectMapScalingEvent(
			zoomDelta: zoomDelta,
			timestamp: .now(),
			scalingCenter: nil
		)
		self.process(event: event)
	}

	/// Завершить масштабирование карты, запущенное вызовом `beginScaling`.
	func endScaling() {
		self.endDirectMapControl()
	}

	/// Запустить непрерывное масштабирование карты.
	///
	/// Масштаб будет изменяться в указанном направлении вплоть до вызова `endScaling`.
	func startScaling(inDirection direction: MapScalingDirection) {
		let event = MapScalingBeginEvent(inDirection: direction)
		self.process(event: event)
	}

	/// Остановить непрерывное масштабирование карты.
	///
	/// Если вызвать сразу после `startScaling(inDirection:)`, то произойдёт
	/// масштабирование на некоторую минимальную величину.
	func stopScaling() {
		let event = MapScalingEndEvent()
		self.process(event: event)
	}

	/// Начать таскание карты.
	func beginShifting() {
		self.beginDirectMapControl()
	}

	/// Перетащить карту из точки в указанном направлении.
	func shift(from prevLocation: CGPoint, by vector: CGVector) {
		let fromPoint = ScreenPoint(prevLocation)
		let shift = ScreenShift(vector)
		let event = DirectMapShiftEvent(
			screenShift: shift,
			shiftedPoint: fromPoint,
			timestamp: .now()
		)
		self.process(event: event)
	}

	/// Прекратить таскание карты.
	func endShifting() {
		self.endDirectMapControl()
	}

	/// Начать вращение.
	func beginRotating() {
		self.beginDirectMapControl()
	}

	/// Изменить угол вращения приращением. Угол в радианах.
	func updateRotation(atCenter centerPoint: CGPoint, rotation: CGFloat) {
		let rotationDelta = Arcdegree(value: -Double(rotation)/Double.pi*180.0)
		let rotationCenter = ScreenPoint(centerPoint)
		let event = DirectMapRotationEvent(
			bearingDelta: rotationDelta,
			timestamp: .now(),
			rotationCenter: rotationCenter
		)
		self.process(event: event)
	}

	/// Остановить вращение.
	func endRotating() {
		self.endDirectMapControl()
	}

	/// Начать трёхмерный наклон плоскости карты.
	func beginTilting() {
		self.beginDirectMapControl()
	}

	/// Изменить угол наклона плоскости карты приращением. Угол в градусах.
	func updateTilt(delta: CGFloat) {
		let event = DirectMapTiltEvent(
			delta: Float(delta)/Float.pi*180.0,
			timestamp: .now()
		)
		self.process(event: event)
	}

	/// Остановить наклон карты.
	func endTilting() {
		self.endDirectMapControl()
	}

	/// Запустить поворот карты верхом к северу.
	func rotateNorthToTop() {
		let event = RotateMapToNorthEvent()
		self.process(event: event)
	}

	/// Отменить обработку начатой процедуры.
	func cancel() {
		let event = CancelEvent()
		self.process(event: event)
	}

	func beginDirectMapControl() {
		let event = DirectMapControlBeginEvent()
		self.process(event: event)
	}

	func endDirectMapControl() {
		let event = DirectMapControlEndEvent(timestamp: .now())
		self.process(event: event)
	}
}

private extension TimeInterval {
	static func now() -> TimeInterval {
		TimeInterval(CACurrentMediaTime())
	}
}
