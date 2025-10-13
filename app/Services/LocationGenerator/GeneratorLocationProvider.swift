import Combine
import class CoreLocation.CLLocation
import DGis
import Foundation

class GeneratorLocationProvider: NSObject, ILocationProvider, @unchecked Sendable {
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

		super.init()

		self.locationsCancellable = receiver.locations.receive(on: queue).sink(receiveValue: {
			[weak self] locations in
			self?.handle(locations: locations)
		})
	}

	func setCallbacks(locationCallback: LocationCallback?, availabilityCallback: AvailabilityCallback?) {
		self.locationCallback = locationCallback
		self.availabilityCallback = availabilityCallback
		_ = self.receiver
		let shouldConnect = (locationCallback != nil) as NSNumber
		self.performSelector(
			onMainThread: #selector(self._applyConnection(_:)),
			with: shouldConnect,
			waitUntilDone: false
		)
		self.queue.async {
			self.availabilityCallback?(true)
		}
	}

	func setDesiredAccuracy(_: DesiredAccuracy) {}

	private func handle(locations: [CLLocation]) {
		self.lastLocation = locations.first
		self.locationCallback?(locations)
	}

	@objc
	@MainActor
	private func _applyConnection(_ shouldConnect: NSNumber) {
		if shouldConnect.boolValue {
			self.receiver.connect()
		} else {
			self.receiver.disconnect()
		}
	}
}
