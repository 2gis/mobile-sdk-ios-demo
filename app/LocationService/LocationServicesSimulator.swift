import Dispatch
import CoreLocation
import PlatformSDK

final class LocationServicesSimulator: IPositioningServicesFactory {
	let positioningQueue: PositioningQueue = DispatchQueue(label: "ru.2gis.nativesdk.app.positioning-queue")
	var locationProvider: ILocationProvider?
	var magneticHeadingProvider: IMagneticHeadingProvider?

	init(location: CLLocation, magneticHeading: CLLocationDirection) {
		self.locationProvider = LocationSimulator(
			queue: self.positioningQueue,
			location: location
		)
		self.magneticHeadingProvider = MagneticHeadingSimulator(
			queue: self.positioningQueue,
			magneticHeading: magneticHeading
		)
	}
}
