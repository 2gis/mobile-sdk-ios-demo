import UIKit

class MapGestureBaseEvent {
	let state: MapGestureState

	fileprivate let location: CGPoint
	fileprivate let coordinateSpace: UICoordinateSpace

	init(
		state: MapGestureState,
		location: CGPoint,
		coordinateSpace: UICoordinateSpace
	) {
		self.state = state
		self.location = location
		self.coordinateSpace = coordinateSpace
	}

	func location(in coordinateSpace: UICoordinateSpace) -> CGPoint {
		self.coordinateSpace.convert(self.location, to: coordinateSpace)
	}
}

final class MapGestureEvent: MapGestureBaseEvent, IMapGestureEvent {
}

final class MapGesturePanEvent: MapGestureBaseEvent, IMapGesturePanEvent {
	let translation: CGPoint

	init(
		state: MapGestureState,
		location: CGPoint,
		translation: CGPoint,
		coordinateSpace: UICoordinateSpace
	) {
		self.translation = translation

		super.init(
			state: state,
			location: location,
			coordinateSpace: coordinateSpace
		)
	}
}

final class MapGesturePinchEvent: MapGestureBaseEvent, IMapGesturePinchEvent {
	let scale: CGFloat

	init(
		state: MapGestureState,
		location: CGPoint,
		scale: CGFloat,
		coordinateSpace: UICoordinateSpace
	) {
		self.scale = scale
		super.init(
			state: state,
			location: location,
			coordinateSpace: coordinateSpace
		)
	}
}

final class MapGestureDoubleTapAndPanEvent: MapGestureBaseEvent, IMapGestureDoubleTapAndPanEvent {
	let scale: CGFloat

	init(
		state: MapGestureState,
		location: CGPoint,
		scale: CGFloat,
		coordinateSpace: UICoordinateSpace
	) {
		self.scale = scale
		super.init(
			state: state,
			location: location,
			coordinateSpace: coordinateSpace
		)
	}
}

final class MapGestureRotationEvent: MapGestureBaseEvent, IMapGestureRotationEvent {
	let rotation: CGFloat

	init(
		state: MapGestureState,
		location: CGPoint,
		rotation: CGFloat,
		coordinateSpace: UICoordinateSpace
	) {
		self.rotation = rotation
		super.init(
			state: state,
			location: location,
			coordinateSpace: coordinateSpace
		)
	}
}

final class MapGestureMultitouchEvent: MapGestureBaseEvent, IMapGestureMultitouchEvent {
	let numberOfTouches: Int

	private let locations: [CGPoint]

	init(
		state: MapGestureState,
		locations: [CGPoint],
		coordinateSpace: UICoordinateSpace
	) {
		assert(!locations.isEmpty)

		self.numberOfTouches = locations.count
		self.locations = locations

		super.init(
			state: state,
			location: locations.first ?? .zero,
			coordinateSpace: coordinateSpace
		)
	}

	func locationOfTouch(
		at touchIndex: Int,
		in coordinateSpace: UICoordinateSpace
	) -> CGPoint {
		guard self.locations.indices ~= touchIndex else { return .zero }
		let thisLocation = self.locations[touchIndex]
		return self.coordinateSpace.convert(thisLocation, to: coordinateSpace)
	}
}
