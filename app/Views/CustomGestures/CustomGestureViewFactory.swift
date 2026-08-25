import DGis
import UIKit

class CustomGestureViewFactory: IMapGestureUIViewFactory, @unchecked Sendable {
	@MainActor
	func makeGestureView(
		map _: Map,
		eventProcessor: IMapEventProcessor,
		coordinateSpace: IMapCoordinateSpace
	) -> UIView & IMapGestureUIView {
		CustomMapGestureView(mapEventProcessor: eventProcessor, mapCoordinateSpace: coordinateSpace)
	}
}
