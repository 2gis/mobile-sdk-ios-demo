import Combine
import DGis
import SwiftUI

@MainActor
final class RotationGestureSettingsViewModel: ObservableObject {
	@Published var rotationEnabled: Bool = true

	@Published var rotationThresholdAngleDiffDeg: Float
	@Published var rotationThresholdDistanceDiffMm: Float
	@Published var rotationThresholdInScalingAngleDiffDeg: Float
	@Published var rotationThresholdInScalingDistanceDiffMm: Float

	@Published var actionPoint: ActionPoint

	@Published var rotationKinematicEnabled: Bool = true
	@Published var decelerationCoefficient: Float
	@Published var maxInitialForwardAngularSpeed: Float
	@Published var initialBackwardAngularSpeed: Float
	@Published var angleThreshold: Float

	var targetGeoPoint: GeoPointWithElevation?

	private let gestureManager: GestureManager
	private let rotationGestureSettings: RotationGestureSettings

	init(
		gestureManager: GestureManager,
		targetGeoPoint: GeoPointWithElevation?
	) {
		self.gestureManager = gestureManager
		self.rotationGestureSettings = gestureManager.rotationSettings
		self.rotationEnabled = gestureManager.enabledGestures.contains(.rotation)
		self.rotationThresholdAngleDiffDeg = self.rotationGestureSettings.recognizeSettings.rotationThreshold.angleDiffDeg
		self.rotationThresholdDistanceDiffMm = self.rotationGestureSettings.recognizeSettings.rotationThreshold.distanceDiffMm
		self.rotationThresholdInScalingAngleDiffDeg = self.rotationGestureSettings.recognizeSettings.rotationThresholdInScaling.angleDiffDeg
		self.rotationThresholdInScalingDistanceDiffMm = self.rotationGestureSettings.recognizeSettings.rotationThresholdInScaling.angleDiffDeg
		self.rotationKinematicEnabled = self.rotationGestureSettings.kinematicSettings.enabled
		self.decelerationCoefficient = self.rotationGestureSettings.kinematicSettings.decelerationCoefficient
		self.maxInitialForwardAngularSpeed = self.rotationGestureSettings.kinematicSettings.maxInitialForwardAngularSpeed
		self.initialBackwardAngularSpeed = self.rotationGestureSettings.kinematicSettings.initialBackwardAngularSpeed
		self.angleThreshold = self.rotationGestureSettings.kinematicSettings.angleThreshold
		self.targetGeoPoint = targetGeoPoint
		self.actionPoint = .init(from: self.rotationGestureSettings.rotationCenter)
	}

	func set() {
		guard self.rotationEnabled else {
			self.gestureManager.disableGesture(gesture: .rotation)
			return
		}
		self.gestureManager.enableGesture(gesture: .rotation)

		self.rotationGestureSettings.recognizeSettings = .init(
			rotationThreshold: .init(
				angleDiffDeg: self.rotationThresholdAngleDiffDeg,
				distanceDiffMm: self.rotationThresholdDistanceDiffMm
			),
			rotationThresholdInScaling: .init(
				angleDiffDeg: self.rotationThresholdInScalingAngleDiffDeg,
				distanceDiffMm: self.rotationThresholdInScalingDistanceDiffMm
			)
		)
		self.rotationGestureSettings.rotationCenter = self.actionPoint.makeGestureActionPoint(targetGeoPoint: self.targetGeoPoint)
		self.rotationGestureSettings.kinematicSettings = .init(
			enabled: self.rotationKinematicEnabled,
			decelerationCoefficient: self.decelerationCoefficient,
			maxInitialForwardAngularSpeed: self.maxInitialForwardAngularSpeed,
			initialBackwardAngularSpeed: self.initialBackwardAngularSpeed,
			angleThreshold: self.angleThreshold
		)
	}
}
