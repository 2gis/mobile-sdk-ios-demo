import Combine
import DGis
import SwiftUI

final class MoveController: CameraMoveController {
	private let initialPosition: CameraPosition

	init(initialPosition: CameraPosition) {
		self.initialPosition = initialPosition
	}

	func position(time: TimeInterval) -> CameraPosition {
		let zoomOffset = Float(sin(time * 1000)) * 0.0000001
		return CameraPosition(
			point: self.initialPosition.point,
			zoom: Zoom(value: max(0.0, self.initialPosition.zoom.value + zoomOffset)),
			tilt: self.initialPosition.tilt,
			bearing: self.initialPosition.bearing
		)
	}

	func animationTime() -> TimeInterval {
		.infinity
	}
}

@MainActor
final class FpsRestrictionsDemoViewModel: ObservableObject, @unchecked Sendable {
	@Published var maxRefreshRate = Double(UIScreen.main.maximumFramesPerSecond)
	@Published var currentFps: Double = 0.0
	@Published var maxFps = Double(UIScreen.main.maximumFramesPerSecond) {
		didSet {
			if self.maxFps != oldValue {
				self.energyConsumption.maxFps = Int(self.maxFps)
			}
		}
	}

	@Published var powerSavingMaxFps = Double(UIScreen.main.maximumFramesPerSecond) * 0.5 {
		didSet {
			if self.powerSavingMaxFps != oldValue {
				self.energyConsumption.powerSavingMaxFps = Int(self.powerSavingMaxFps)
			}
		}
	}

	private let map: Map
	private let energyConsumption: IEnergyConsumption

	private var cameraAnimated: DGis.Future<CameraAnimatedMoveResult>?

	init(
		map: Map,
		energyConsumption: IEnergyConsumption
	) {
		self.map = map
		self.energyConsumption = energyConsumption
		self.energyConsumption.setFpsCallback { [weak self] fps in
			DispatchQueue.main.async {
				self?.currentFps = fps
			}
		}
	}

	func startCameraMoving() {
		self.cameraAnimated = self.map.camera.move(moveController: MoveController(initialPosition: self.map.camera.position))
	}
}
