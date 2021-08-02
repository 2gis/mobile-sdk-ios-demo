import Foundation

/// Обработчик событий о возможных жестах, в т.ч. нажатия.
/// У каждого события возможны состояния: `began`, `changed`, `ended`,
/// `cancelled`.
///
/// Все методы обязаны отрабатывать на главном потоке.
protocol IMapGestureInputController: AnyObject {
	func didPan(with event: IMapGesturePanEvent)
	func didTwoFingerPan(with event: IMapGesturePanEvent)
	func didDoubleTapAndPan(with event: IMapGestureDoubleTapAndPanEvent)
	func didRotate(with event: IMapGestureRotationEvent)
	func didPinch(with event: IMapGesturePinchEvent)
	func didDoubleTap(with event: IMapGestureEvent)
	func didTwoFingerTap(with event: IMapGestureEvent)
}
