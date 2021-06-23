import CoreLocation

final class LocationService: NSObject {

	private let locationManager = CLLocationManager()
	private var locationClosure: ((CLLocationCoordinate2D) -> Void)?

	func getCurrentPosition(_ position: @escaping (CLLocationCoordinate2D) -> Void) {
		self.locationManager.requestWhenInUseAuthorization()
		if CLLocationManager.locationServicesEnabled() {
			self.locationManager.delegate = self
			self.locationManager.startUpdatingLocation()
			self.locationClosure = position
		}
	}

	func startBackgroundLocationMonitoring() {
		if !CLLocationManager.locationServicesEnabled() {
			self.locationManager.requestWhenInUseAuthorization()
		}
		self.locationManager.allowsBackgroundLocationUpdates = true
		self.locationManager.startUpdatingLocation()
	}
}

extension LocationService: CLLocationManagerDelegate {
	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let location = manager.location?.coordinate else { return }
		self.locationClosure?(location)
		self.locationManager.stopUpdatingLocation()
	}
}
