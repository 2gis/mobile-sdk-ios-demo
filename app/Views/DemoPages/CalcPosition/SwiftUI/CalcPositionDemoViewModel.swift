import Combine
import DGis
import SwiftUI

final class CalcPositionDemoViewModel: ObservableObject, @unchecked Sendable {
	@Published var paddingRect = PaddingRect()
	@Published var tilt = Tilt()
	@Published var bearing = Bearing()
	@Published var calcPositionWay = CalcPositionWays.cameraParams
	@Published var isErrorAlertShown: Bool = false
	let map: Map
	private let mapObjectManager: MapObjectManager
	private let logger: ILogger
	private let imageFactory: IImageFactory
	private var moveCameraCancellable: DGis.Cancellable?

	lazy var selectedObjects: CalcPositionMapObjects = .marker

	private lazy var objectFactory = CalcPositionMapObjectsFactory(imageFactory: self.imageFactory)

	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	init(
		map: Map,
		logger: ILogger,
		imageFactory: IImageFactory
	) {
		self.map = map
		self.logger = logger
		self.imageFactory = imageFactory
		self.mapObjectManager = MapObjectManager(map: map)

		for item in CalcPositionMapObjects.allCases {
			self.mapObjectManager.addObjects(objects: item.getObjects(factory: self.objectFactory))
		}
		if let position = try? calcPosition(
				camera: self.map.camera,
				objects: self.selectedObjects.getObjects(factory: self.objectFactory)
			) {
			self.cameraSetPosition(position)
		}
	}

	func applyCameraSettings() {
		switch self.calcPositionWay {
		case .cameraParams:
			self.useCameraParams()
		case .clonedCameraParams:
			self.useClonedCameraParams()
		case .calcPositionParams:
			self.useCalcPositionParams()
		@unknown default:
			fatalError("Unknown type: \(self.calcPositionWay)")
		}
	}

	private func useCameraParams() {
		self.changeCameraSettings(
			camera: self.map.camera,
			padding: self.paddingRect.toDGisPadding(),
			tilt: self.tilt,
			bearing: self.bearing
		)
		guard let position = try? calcPosition(
				camera: self.map.camera,
				objects: self.selectedObjects.getObjects(factory: self.objectFactory)
			) else {
			self.errorMessage = "Failed to calculate camera position"
			return
		}
		self.cameraMove(position)
	}

	private func useClonedCameraParams() {
		self.resetCameraSettings()
		let newCamera = self.map.camera.clone()
		self.changeCameraSettings(
			camera: newCamera,
			padding: self.paddingRect.toDGisPadding(),
			tilt: self.tilt,
			bearing: self.bearing
		)
		guard let position = try? calcPosition(
				camera: newCamera,
				objects: self.selectedObjects.getObjects(factory: self.objectFactory)
			) else {
			self.errorMessage = "Failed to calculate cloned camera position"
			return
		}
		self.cameraMove(position)
		self.changeCameraSettings(
			camera: self.map.camera,
			padding: self.paddingRect.toDGisPadding(),
			tilt: self.tilt,
			bearing: self.bearing
		)
	}

	private func useCalcPositionParams() {
		self.resetCameraSettings()
		guard let position = try? calcPosition(
				camera: self.map.camera,
				objects: self.selectedObjects.getObjects(factory: self.objectFactory),
				screenArea: self.paddingRect.toDGisPadding(),
				tilt: self.tilt,
				bearing: self.bearing
			) else {
			self.errorMessage = "Failed to calculate camera position with parameters"
			return
		}
		self.cameraMove(position)
	}

	private func resetCameraSettings() {
		self.map.camera.padding = Padding()
		do {
			try self.map.camera.changePosition(
				positionChange: .init(
					tilt: Tilt(),
					bearing: Bearing()
				)
			)
		} catch {
			self.errorMessage = "Failed to reset camera settings: \(error.localizedDescription)"
			return
		}
	}

	private func changeCameraSettings(camera: BaseCamera, padding: Padding, tilt: Tilt, bearing: Bearing) {
		camera.padding = padding
		do {
			try camera.changePosition(
				positionChange: .init(
					tilt: tilt,
					bearing: bearing
				)
			)
		} catch {
			self.errorMessage = "Failed to update camera settings: \(error.localizedDescription)"
			return
		}
	}

	private func cameraMove(_ position: CameraPosition) {
		let cameraMoveQueue = DispatchQueue(
			label: "ru.mobile.sdk.app.camera-move-queue",
			qos: .default
		)
		cameraMoveQueue.async { [weak self] in
			Task { @MainActor [weak self] in
				guard let self else { return }
				self.moveCameraCancellable?.cancel()
				self.moveCameraCancellable = self.map.camera.move(
					position: position,
					time: 2
				).sinkOnMainThread { _ in
				} failure: { [weak self] error in
					Task { @MainActor [weak self] in
						self?.logger.error("Something went wrong: \(error.localizedDescription)")
					}
				}
			}
		}
	}

	private func cameraSetPosition(_ position: CameraPosition) {
		do {
			try self.map.camera.setPosition(position: position)
		} catch {
			self.errorMessage = "Failed to set camera position: \(error.localizedDescription)"
			return
		}
	}
}
