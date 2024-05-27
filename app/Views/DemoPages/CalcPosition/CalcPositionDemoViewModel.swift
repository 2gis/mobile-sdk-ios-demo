import SwiftUI
import DGis

final class CalcPositionDemoViewModel: ObservableObject {
	@Published var paddingRect = PaddingRect()
	@Published var tilt = Tilt()
	@Published var bearing = Bearing()
	@Published var calcPositionWay = CalcPositionWays.cameraParams
	@Published var isErrorAlertShown: Bool = false
	let map: Map
	private let mapObjectManager: MapObjectManager
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
		imageFactory: IImageFactory
	) {
		self.map = map
		self.imageFactory = imageFactory
		self.mapObjectManager = MapObjectManager(map: map)
		
		CalcPositionMapObjects.allCases.forEach { item in
			self.mapObjectManager.addObjects(objects: item.getObjects(factory: self.objectFactory))
		}
		self.cameraSetPosition(
			calcPosition(
				camera: self.map.camera,
				objects: self.selectedObjects.getObjects(factory: objectFactory))
		)
	}

	func applyCameraSettings() {
		switch calcPositionWay {
		case .cameraParams:
			self.useCameraParams()
		case .clonedCameraParams:
			self.useClonedCameraParams()
		case .calcPositionParams:
			self.useCalcPositionParams()
		}
	}
	
	private func useCameraParams() {
		self.changeCameraSettings(
			camera: self.map.camera,
			padding: paddingRect.toDGisPadding(),
			tilt: self.tilt,
			bearing: self.bearing
		)
		self.cameraMove(
			calcPosition(
				camera: self.map.camera,
				objects: self.selectedObjects.getObjects(factory: objectFactory))
		)
	}
	
	private func useClonedCameraParams() {
		self.resetCameraSettings()
		let newCamera = self.map.camera.clone()
		self.changeCameraSettings(
			camera: newCamera,
			padding: paddingRect.toDGisPadding(),
			tilt: self.tilt,
			bearing: self.bearing
		)
		self.cameraMove(
			calcPosition(
				camera: newCamera,
				objects: self.selectedObjects.getObjects(factory: objectFactory))
		)
		self.changeCameraSettings(
			camera: self.map.camera,
			padding: paddingRect.toDGisPadding(),
			tilt: self.tilt,
			bearing: self.bearing
		)
	}
	
	private func useCalcPositionParams() {
		self.resetCameraSettings()
		self.cameraMove(
			calcPosition(
				camera: self.map.camera,
				objects: self.selectedObjects.getObjects(factory: objectFactory),
				screenArea: paddingRect.toDGisPadding(),
				tilt: self.tilt,
				bearing: self.bearing
			)
		)
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
			self.errorMessage = ("Failed to reset camera settings: \(error.localizedDescription)")
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
			self.errorMessage = ("Failed to update camera settings: \(error.localizedDescription)")
			return
		}
	}

	private func cameraMove(_ position: CameraPosition) {
		let cameraMoveQueue: DispatchQueue = DispatchQueue(
			label: "ru.mobile.sdk.app.camera-move-queue",
			qos: .default
		)
		cameraMoveQueue.async {
			self.moveCameraCancellable?.cancel()
			self.moveCameraCancellable = self.map.camera.move(
				position: position,
				time: 2
			).sink { _ in
				return
			} failure: { [weak self] error in
				self?.errorMessage = ("Failed to move the camera: \(error.localizedDescription)")
			}
		}
	}

	private func cameraSetPosition(_ position: CameraPosition) {
		do {
			try self.map.camera.setPosition(position: position)
		} catch {
			self.errorMessage = ("Failed to set camera position: \(error.localizedDescription)")
			return
		}
	}
}

