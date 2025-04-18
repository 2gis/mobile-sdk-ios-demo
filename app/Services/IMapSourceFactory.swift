import Foundation
import DGis

/// Фабрика источников карты.
protocol IMapSourceFactory {
	func makeMyLocationMapObjectSource(
		bearingSource: BearingSource
	) -> MyLocationMapObjectSource

	func makeMyLocationMapObjectSource(
		controllerSettings: MyLocationControllerSettings
	) -> MyLocationMapObjectSource

	func makeSmoothMyLocationMapObjectSource(
		bearingSource: BearingSource
	) -> MyLocationMapObjectSource

	func makeRoadEventSource() -> RoadEventSource
}

struct MapSourceFactory: IMapSourceFactory {
	private let context: Context
	private let settingsService: ISettingsService

	init(context: Context, settingsService: ISettingsService) {
		self.context = context
		self.settingsService = settingsService
	}

	func makeMyLocationMapObjectSource(
		bearingSource: BearingSource
	) -> MyLocationMapObjectSource {
		MyLocationMapObjectSource(
			context: self.context,
			controllerSettings: MyLocationControllerSettings(bearingSource: bearingSource, animationDuration: 0),
			markerType: self.settingsService.geolocationMarkerType.markerType
		)
	}

	func makeMyLocationMapObjectSource(
		controllerSettings: MyLocationControllerSettings
	) -> MyLocationMapObjectSource {
		MyLocationMapObjectSource(
			context: self.context,
			controllerSettings: controllerSettings,
			markerType: self.settingsService.geolocationMarkerType.markerType
		)
	}

	func makeSmoothMyLocationMapObjectSource(
		bearingSource: BearingSource
	) -> MyLocationMapObjectSource {
		MyLocationMapObjectSource(
			context: self.context,
			controllerSettings: MyLocationControllerSettings(bearingSource: bearingSource),
			markerType: self.settingsService.geolocationMarkerType.markerType
		)
	}

	func makeRoadEventSource() -> RoadEventSource {
		RoadEventSource(context: self.context)
	}
}
