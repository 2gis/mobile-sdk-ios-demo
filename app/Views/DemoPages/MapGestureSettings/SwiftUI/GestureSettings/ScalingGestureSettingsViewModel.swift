import Combine
import DGis
import SwiftUI

@MainActor
final class ScalingGestureSettingsViewModel: ObservableObject {
	@Published var scalingEnabled: Bool = true

	@Published var scaleRatioThreshold: Float
	@Published var scaleRatioThresholdInRotation: Float
	@Published var zoomScaleRatio: Float
	@Published var scaleLogDiffPerMm: Float
	@Published var disableZoom: Bool = true

	@Published var actionPoint: ActionPoint

	@Published var scalingKinematicEnabled: Bool = true
	@Published var decelerationCoefficient: Float
	@Published var maxInitialForwardZoomSpeed: Float
	@Published var zoomThreshold: Float

	var targetGeoPoint: GeoPointWithElevation?

	private let gestureManager: GestureManager
	private let scalingGestureSettings: ScalingGestureSettings

	init(
		gestureManager: GestureManager,
		targetGeoPoint: GeoPointWithElevation?
	) {
		self.gestureManager = gestureManager
		self.scalingEnabled = gestureManager.enabledGestures.contains(.scaling)
		self.scalingGestureSettings = gestureManager.scalingSettings
		self.scaleRatioThreshold = self.scalingGestureSettings.recognizeSettings.scaleRatioThreshold
		self.scaleRatioThresholdInRotation = self.scalingGestureSettings.recognizeSettings.scaleRatioThresholdInRotation
		self.zoomScaleRatio = self.scalingGestureSettings.recognizeSettings.zoomScaleRatio
		self.scaleLogDiffPerMm = self.scalingGestureSettings.recognizeSettings.scaleLogDiffPerMm
		self.disableZoom = self.scalingGestureSettings.recognizeSettings.disableZoom
		self.scalingKinematicEnabled = self.scalingGestureSettings.kinematicSettings.enabled
		self.decelerationCoefficient = self.scalingGestureSettings.kinematicSettings.decelerationCoefficient
		self.maxInitialForwardZoomSpeed = self.scalingGestureSettings.kinematicSettings.maxInitialForwardZoomSpeed
		self.zoomThreshold = self.scalingGestureSettings.kinematicSettings.zoomThreshold
		self.targetGeoPoint = targetGeoPoint
		self.actionPoint = .init(from: self.scalingGestureSettings.scalingCenter)
	}

	func set() {
		guard self.scalingEnabled else {
			self.gestureManager.disableGesture(gesture: .scaling)
			return
		}
		self.gestureManager.enableGesture(gesture: .scaling)

		self.scalingGestureSettings.recognizeSettings = .init(
			scaleRatioThreshold: self.scaleRatioThreshold,
			scaleRatioThresholdInRotation: self.scaleRatioThresholdInRotation,
			zoomScaleRatio: self.zoomScaleRatio,
			scaleLogDiffPerMm: self.scaleLogDiffPerMm,
			disableZoom: self.disableZoom
		)
		self.scalingGestureSettings.scalingCenter = self.actionPoint.makeGestureActionPoint(targetGeoPoint: self.targetGeoPoint)
		self.scalingGestureSettings.kinematicSettings = .init(
			enabled: self.scalingKinematicEnabled,
			decelerationCoefficient: self.decelerationCoefficient,
			maxInitialForwardZoomSpeed: self.maxInitialForwardZoomSpeed,
			zoomThreshold: self.zoomThreshold
		)
	}
}
