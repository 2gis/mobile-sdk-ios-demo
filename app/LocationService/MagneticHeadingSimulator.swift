import CoreLocation
import PlatformSDK

struct MagneticHeadingSimulator: IMagneticHeadingProvider {
	private let queue: DispatchQueue
	private let magneticHeading: CLLocationDirection

	init(queue: DispatchQueue, magneticHeading: CLLocationDirection) {
		self.queue = queue
		self.magneticHeading = magneticHeading
		_ = SimulatedHeading(magneticHeading: 0)
	}

	func setCallbacks(
		headingCallback: HeadingCallback?,
		availabilityCallback: AvailabilityCallback?
	) {
		availabilityCallback?(true)
		let heading = SimulatedHeading(magneticHeading: self.magneticHeading)
		headingCallback?(heading)
	}
}

private final class SimulatedHeading: CLHeading {
	override var magneticHeading: CLLocationDirection {
		get {
			self._magneticHeading
		}
		set {
			self._magneticHeading = newValue
		}
	}

	override var headingAccuracy: CLLocationDirectionAccuracy {
		get {
			self._headingAccuracy
		}
		set {
			self._headingAccuracy = newValue
		}
	}

	override var timestamp: Date {
		self._timestamp
	}

	private var _magneticHeading: CLLocationDirection
	private var _headingAccuracy: CLLocationDirectionAccuracy
	private var _timestamp: Date

	init(magneticHeading: CLLocationDirection, headingAccuracy: CLLocationDirectionAccuracy = 1) {
		self._magneticHeading = magneticHeading
		self._headingAccuracy = headingAccuracy
		self._timestamp = Date()
		super.init()
	}

	required init?(coder: NSCoder) {
		fatalError("This type cannot be decoded")
	}
}
