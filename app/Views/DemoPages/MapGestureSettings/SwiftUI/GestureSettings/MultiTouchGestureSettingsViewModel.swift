import Combine
import DGis
import SwiftUI

@MainActor
final class MultiTouchGestureSettingsViewModel: ObservableObject {
	@Published var multiTouchEnabled: Bool = true

	@Published var multitouchShiftThresholdMm: Float

	private let gestureManager: GestureManager
	private let multiTouchGestureSettings: MultiTouchGestureSettings

	init(
		gestureManager: GestureManager
	) {
		self.gestureManager = gestureManager
		self.multiTouchEnabled = gestureManager.enabledGestures.contains(.multiTouchShift)
		self.multiTouchGestureSettings = gestureManager.multitouchShiftSettings
		self.multitouchShiftThresholdMm = self.multiTouchGestureSettings.recognizeSettings.multitouchShiftThresholdMm
	}

	func set() {
		guard self.multiTouchEnabled else {
			self.gestureManager.disableGesture(gesture: .multiTouchShift)
			return
		}
		self.gestureManager.enableGesture(gesture: .multiTouchShift)

		self.multiTouchGestureSettings.recognizeSettings = .init(
			multitouchShiftThresholdMm: self.multitouchShiftThresholdMm
		)
	}
}
