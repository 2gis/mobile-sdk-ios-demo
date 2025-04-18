import CoreLocation

final class LocationService: NSObject, ILocationService {
	private let locationManager = CLLocationManager()
	private var locationClosure: ((CLLocationCoordinate2D?) -> Void)?

	func getCurrentPosition(_ position: @escaping (CLLocationCoordinate2D?) -> Void) {
		self.locationManager.requestWhenInUseAuthorization()
		if CLLocationManager.locationServicesEnabled() {
			self.locationManager.delegate = self
			self.locationManager.startUpdatingLocation()
			self.locationClosure = position
		}
	}

	private func handle(_ location: CLLocation?) {
		self.locationClosure?(location?.coordinate)
		self.locationClosure = nil
		self.locationManager.stopUpdatingLocation()
	}
}

extension LocationService: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		self.handle(locations.first)
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		self.handle(nil)
	}
}
