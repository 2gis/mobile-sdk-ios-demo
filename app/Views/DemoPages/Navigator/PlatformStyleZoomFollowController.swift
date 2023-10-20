import DGis

final class PlatformStyleZoomFollowController: CustomFollowController {
	private var notifier: NewValuesNotifier? = nil
	private var styleZoomValue: StyleZoom? = nil

	func availableValues() -> FollowValueOptionSet {
		.styleZoom
	}

	func requestValues(values: FollowValueOptionSet) {
	}

	func setNewValuesNotifier(notifier: NewValuesNotifier?) {
		self.notifier = notifier
	}

	func coordinates() -> GeoPoint? {
		nil
	}

	func bearing() -> Bearing? {
		nil
	}

	func tilt() -> Tilt? {
		nil
	}

	func setStyleZoom(styleZoom: StyleZoom?) {
		self.styleZoomValue = styleZoom
		self.notifier?.sendNotification()
	}

	func styleZoom() -> StyleZoom? {
		self.styleZoomValue
	}
}
