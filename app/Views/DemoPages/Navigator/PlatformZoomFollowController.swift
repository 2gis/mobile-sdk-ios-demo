import DGis

final class PlatformZoomFollowController: CustomFollowController {
	private var notifier: NewValuesNotifier? = nil
	private var zoomValue: Zoom? = nil

	func availableValues() -> FollowValueOptionSet {
		.zoom
	}

	func requestValues(values: FollowValueOptionSet) {
	}

	func setNewValuesNotifier(notifier: NewValuesNotifier?) {
		self.notifier = notifier
	}

	func coordinates() -> GeoPoint? {
		nil
	}

	func satelliteBearing() -> Bearing? {
		nil
	}

	func magneticBearing() -> Bearing? {
		nil
	}

	func tilt() -> Tilt? {
		nil
	}

	func setZoom(zoom: Zoom?) {
		self.zoomValue = zoom
		self.notifier?.sendNotification()
	}

	func zoom() -> Zoom? {
		self.zoomValue
	}

	func accuracy() -> Double? {
		nil
	}
}
