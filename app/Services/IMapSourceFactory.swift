import Foundation
import DGis

/// Фабрика источников карты.
protocol IMapSourceFactory {
	func makeMyLocationMapObjectSource() -> MyLocationMapObjectSource

	func makeRoadEventSource() -> RoadEventSource
}

struct MapSourceFactory: IMapSourceFactory {
	private let context: Context

	init(context: Context) {
		self.context = context
	}

	func makeMyLocationMapObjectSource() -> MyLocationMapObjectSource {
		MyLocationMapObjectSource(
			context: self.context,
			controllerSettings: MyLocationControllerSettings(bearingSource: .auto)
		)
	}

	func makeRoadEventSource() -> RoadEventSource {
		RoadEventSource(context: self.context)
	}
}
