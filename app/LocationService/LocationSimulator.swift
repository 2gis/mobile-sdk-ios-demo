import CoreLocation
import PlatformSDK

struct LocationSimulator: ILocationProvider {
	private let queue: DispatchQueue
	private let location: CLLocation

	init(queue: DispatchQueue, location: CLLocation) {
		self.queue = queue
		self.location = location
	}

	var lastLocation: CLLocation? {
		self.location
	}

	func setCallbacks(
		locationCallback: LocationCallback?,
		availabilityCallback: AvailabilityCallback?
	) {
		availabilityCallback?(true)
		self.queue.async {
			locationCallback?([self.location])
		}
	}

	func setDesiredAccuracy(_ accuracy: DesiredPositioningAccuracy) {
	}
}
