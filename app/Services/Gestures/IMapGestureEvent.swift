import UIKit

typealias MapGestureState = UIGestureRecognizer.State

/// Событие об изменении состояния жеста над картой.
protocol IMapGestureEvent {
	var state: MapGestureState { get }

	/// Возвращает координату события, преобразованную в указанное
	/// координатное пространство.
	func location(in coordinateSpace: UICoordinateSpace) -> CGPoint
}

protocol IMapGesturePanEvent: IMapGestureEvent {
	var translation: CGPoint { get }
}

protocol IMapGesturePinchEvent: IMapGestureEvent {
	var scale: CGFloat { get }
}

protocol IMapGestureDoubleTapAndPanEvent: IMapGestureEvent {
	var scale: CGFloat { get }
}

protocol IMapGestureRotationEvent: IMapGestureEvent {
	var rotation: CGFloat { get }
}

protocol IMapGestureMultitouchEvent: IMapGestureEvent {
	/// Число активных нажатий.
	var numberOfTouches: Int { get }

	/// Место нажатия по указанному индексу. Если индексу не соответствует `UITouch`-объект, возвращается `.zero`.
	func locationOfTouch(
		at touchIndex: Int,
		in coordinateSpace: UICoordinateSpace
	) -> CGPoint
}
