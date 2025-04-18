import SwiftUI
import DGis

final class CameraMovesDemoViewModel: ObservableObject {
	@Published var showActionSheet = false
	private let map: Map
	private let logger: ILogger
	private var locationService: ILocationService?
	private var moveCameraCancellable: DGis.Cancellable?

	init(
		map: Map,
		logger: ILogger,
		mapSourceFactory: IMapSourceFactory
	) {
		self.map = map
		self.logger = logger

		let locationSource = mapSourceFactory.makeMyLocationMapObjectSource(
			bearingSource: .satellite
		)
		map.addSource(source: locationSource)
	}

	func testCamera() {
		self.move(at: 0)
	}

	func showCurrentPosition() {
		self.locationService?.getCurrentPosition { (coordinatesOptional) in
			if let coordinates = coordinatesOptional {
				self.moveCameraCancellable?.cancel()
				self.moveCameraCancellable = self.map
					.camera
					.move(
						position: CameraPosition(
							point: GeoPoint(latitude: .init(value: coordinates.latitude), longitude: .init(value: coordinates.longitude)),
							zoom: .init(value: 14),
							tilt: .init(value: 15),
							bearing: .init(value: 0)
						),
						time: 1.0,
						animationType: .linear
					).sink { [weak self] _ in
						self?.logger.info("Move to current location")
					} failure: { [weak self] error in
						self?.logger.error("Something went wrong: \(error.localizedDescription)")
					}
			}
		}
	}

	private func move(at index: Int) {
		guard index < CameraPath.moscowDefault.count else { return }
		let tuple = CameraPath.moscowDefault[index]
		DispatchQueue.main.async {
			self.moveCameraCancellable?.cancel()
			self.moveCameraCancellable = self.map
				.camera
				.move(
					position: tuple.position,
					time: tuple.time,
					animationType: tuple.type
				).sink { [weak self] _ in
					self?.move(at: index + 1)
				} failure: { [weak self] error in
					self?.logger.error("Something went wrong: \(error.localizedDescription)")
				}
		}
	}
}
