import Foundation
import DGis

/// Фабрика источников карты.
protocol IMapSourceFactory {
	func makeMyLocationMapObjectSource(
		directionBehaviour: MyLocationDirectionBehaviour
	) -> MyLocationMapObjectSource

	func makeSmoothMyLocationMapObjectSource(
		directionBehaviour: MyLocationDirectionBehaviour
	) -> MyLocationMapObjectSource

	func makeRoadEventSource() -> RoadEventSource
}

struct MapSourceFactory: IMapSourceFactory {
	private let context: Context

	init(context: Context) {
		self.context = context
	}

	func makeMyLocationMapObjectSource(
		directionBehaviour: MyLocationDirectionBehaviour
	) -> MyLocationMapObjectSource {
		MyLocationMapObjectSource(
			context: self.context,
			directionBehaviour: directionBehaviour,
			controller: createRawMyLocationController()
		)
	}

	func makeSmoothMyLocationMapObjectSource(
		directionBehaviour: MyLocationDirectionBehaviour
	) -> MyLocationMapObjectSource {
		MyLocationMapObjectSource(
			context: self.context,
			directionBehaviour: directionBehaviour,
			controller: createSmoothMyLocationController()
		)
	}

	func makeRoadEventSource() -> RoadEventSource {
		RoadEventSource(context: self.context)
	}
}
