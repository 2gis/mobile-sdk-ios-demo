import Combine
import DGis
import SwiftUI

@MainActor
final class TiltGestureSettingsViewModel: ObservableObject {
	@Published var tiltEnabled: Bool = true

	@Published var lenOnDegreeMm: Float
	@Published var horizontalSwerveDeg: Float
	@Published var verticalSwerveDeg: Float
	@Published var thresholdMm: Float
	@Published var maxParallelsDeviationDeg: Float

	@Published var tiltKinematicEnabled: Bool = true
	@Published var decelerationCoefficient: Float
	@Published var initialForwardSpeedMultiplier: Float
	@Published var maxInitialForwardAngularSpeed: Float
	@Published var minTiltAdditionalBorder: Float
	@Published var maxTiltAdditionalBorder: Float
	@Published var tiltThreshold: Float

	private let gestureManager: GestureManager
	private let tiltGestureSettings: TiltGestureSettings

	init(
		gestureManager: GestureManager
	) {
		self.gestureManager = gestureManager
		self.tiltEnabled = gestureManager.enabledGestures.contains(.tilt)
		self.tiltGestureSettings = gestureManager.tiltSettings
		self.lenOnDegreeMm = self.tiltGestureSettings.recognizeSettings.lenOnDegreeMm
		self.horizontalSwerveDeg = self.tiltGestureSettings.recognizeSettings.horizontalSwerveDeg
		self.verticalSwerveDeg = self.tiltGestureSettings.recognizeSettings.verticalSwerveDeg
		self.thresholdMm = self.tiltGestureSettings.recognizeSettings.thresholdMm
		self.maxParallelsDeviationDeg = self.tiltGestureSettings.recognizeSettings.maxParallelsDeviationDeg
		self.tiltKinematicEnabled = self.tiltGestureSettings.kinematicSettings.enabled
		self.decelerationCoefficient = self.tiltGestureSettings.kinematicSettings.decelerationCoefficient
		self.initialForwardSpeedMultiplier = self.tiltGestureSettings.kinematicSettings.initialForwardSpeedMultiplier
		self.maxInitialForwardAngularSpeed = self.tiltGestureSettings.kinematicSettings.maxInitialForwardAngularSpeed
		self.minTiltAdditionalBorder = self.tiltGestureSettings.kinematicSettings.minTiltAdditionalBorder.value
		self.maxTiltAdditionalBorder = self.tiltGestureSettings.kinematicSettings.maxTiltAdditionalBorder.value
		self.tiltThreshold = self.tiltGestureSettings.kinematicSettings.tiltThreshold
	}

	func set() {
		guard self.tiltEnabled else {
			self.gestureManager.disableGesture(gesture: .tilt)
			return
		}
		self.gestureManager.enableGesture(gesture: .tilt)

		self.tiltGestureSettings.recognizeSettings = .init(
			lenOnDegreeMm: self.lenOnDegreeMm,
			horizontalSwerveDeg: self.horizontalSwerveDeg,
			verticalSwerveDeg: self.verticalSwerveDeg,
			thresholdMm: self.thresholdMm,
			maxParallelsDeviationDeg: self.maxParallelsDeviationDeg
		)
		self.tiltGestureSettings.kinematicSettings = .init(
			enabled: self.tiltKinematicEnabled,
			decelerationCoefficient: self.decelerationCoefficient,
			initialForwardSpeedMultiplier: self.initialForwardSpeedMultiplier,
			maxInitialForwardAngularSpeed: self.maxInitialForwardAngularSpeed,
			minTiltAdditionalBorder: Tilt(floatLiteral: self.minTiltAdditionalBorder),
			maxTiltAdditionalBorder: Tilt(floatLiteral: self.maxTiltAdditionalBorder),
			tiltThreshold: self.tiltThreshold
		)
	}
}
