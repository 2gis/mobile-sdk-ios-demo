import UIKit
import DGis

/// Фабрика обработки жестов.
public struct MapGestureViewFactory: IMapGestureViewFactory {
	public func makeGestureView(
		map: Map,
		eventProcessor: IMapEventProcessor,
		coordinateSpace: IMapCoordinateSpace
	) -> UIView & IMapGestureView {
		let controller = MapGestureInputController(
			processor: eventProcessor,
			coordinateSpace: coordinateSpace
		)

		let view = MapGestureView()
		view.controller = controller

		return view
	}
}
