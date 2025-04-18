import UIKit
import DGis

class CustomGestureViewFactory: IMapGestureViewFactory {
	func makeGestureView(
		map: Map,
		eventProcessor: IMapEventProcessor,
		coordinateSpace: IMapCoordinateSpace
	) -> UIView & IMapGestureView {
		CustomMapGestureView(mapEventProcessor: eventProcessor, mapCoordinateSpace: coordinateSpace)
	}
}
