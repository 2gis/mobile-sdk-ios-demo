import SwiftUI
import DGis

final class MoveController: CameraMoveController {
	private let initialPosition: CameraPosition

	init(initialPosition: CameraPosition) {
		self.initialPosition = initialPosition
	}

	func position(time: TimeInterval) -> CameraPosition {
		let zoomOffset = sin(time)
		return CameraPosition(point: initialPosition.point, zoom: Zoom(value: max(0.0, initialPosition.zoom.value + Float(zoomOffset))))
	}

	func animationTime() -> TimeInterval {
		return 60.0
	}
}

final class FpsDemoViewModel: ObservableObject {
	@Published var currentFps: Double = 60.0
	@Published var maxFps: String = ""
	@Published var powerSavingMaxFps: String = ""

	private let map: Map
	private let energyConsumption: IEnergyConsumption

	private var cameraAnimated: Future<CameraAnimatedMoveResult>?

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

	func setFps() {
		self.energyConsumption.maxFps = Int(self.maxFps)
		self.energyConsumption.powerSavingMaxFps = Int(self.powerSavingMaxFps)
	}
}
