import Combine
import DGis
import SwiftUI

@MainActor
final class CommonGestureSettingsViewModel: ObservableObject {
	@Published var interGestureTimeout: Double

	private let commonGestureSettings: CommonGestureSettings

	init(
		gestureManager: GestureManager
	) {
		self.commonGestureSettings = gestureManager.commonSettings
		self.interGestureTimeout = self.commonGestureSettings.recognizeSettings.interGestureTimeout
	}

	func set() {
		self.commonGestureSettings.recognizeSettings = .init(interGestureTimeout: self.interGestureTimeout)
	}
}
