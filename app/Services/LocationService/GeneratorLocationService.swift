import CoreLocation
import Combine

final class GeneratorLocationService: NSObject, ILocationService {
	private var locationClosure: ((CLLocationCoordinate2D?) -> Void)?
	private let locationProvider: GeneratorLocationProvider
	private var locationsCancellable: AnyCancellable?

	init(locationProvider: GeneratorLocationProvider) {
		self.locationProvider = locationProvider
	}

	func getCurrentPosition(_ position: @escaping (CLLocationCoordinate2D?) -> Void) {
		self.locationsCancellable = self.locationProvider.locations.first(where: { !$0.isEmpty }).sink(
			receiveValue: { locations in
				position(locations.first?.coordinate)
			}
		)
	}
}
