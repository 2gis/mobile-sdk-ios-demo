import CoreLocation

protocol ILocationService {
	func getCurrentPosition(_ position: @escaping (CLLocationCoordinate2D?) -> Void)
}
