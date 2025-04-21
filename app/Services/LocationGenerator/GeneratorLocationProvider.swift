import Foundation
import Combine
import DGis
import class CoreLocation.CLLocation

class GeneratorLocationProvider: ILocationProvider {
	var lastLocation: CLLocation?
	var locations: CurrentValueSubject<[CLLocation], Never> {
		self.receiver.locations
	}
	private var locationCallback: LocationCallback?
	private var availabilityCallback: AvailabilityCallback?

	private let queue: DispatchQueue
	private let receiver: ILocationGeneratorReceiver
	private var locationsCancellable: AnyCancellable?

	init(queue: DispatchQueue, receiver: ILocationGeneratorReceiver) {
		self.queue = queue
		self.receiver = receiver

		self.locationsCancellable = receiver.locations.receive(on: queue).sink(receiveValue: {
			[weak self] locations in

			self?.handle(locations: locations)
		})
	}

	func setCallbacks(locationCallback: LocationCallback?, availabilityCallback: AvailabilityCallback?) {
		self.locationCallback = locationCallback
		self.availabilityCallback = availabilityCallback
		if locationCallback != nil {
			self.receiver.connect()
		} else {
			self.receiver.disconnect()
		}
		self.queue.async {
			self.availabilityCallback?(true)
		}
	}

	func setDesiredAccuracy(_ accuracy: DesiredAccuracy) {}

	private func handle(locations: [CLLocation]) {
		self.lastLocation = locations.first
		self.locationCallback?(locations)
	}
}
