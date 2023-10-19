import SwiftUI
import Combine
import DGis

final class CameraDemoViewModel: ObservableObject {
	@Published var showActionSheet = false

	private let locationManagerFactory: () -> LocationService?
	private let map: Map
	private var locationService: LocationService?

	private var moveCameraCancellable: DGis.Cancellable?
	private var dataLoadingCancellable: DGis.Cancellable?

	private let testPoints: [(position: CameraPosition, time: TimeInterval, type: CameraAnimationType)] = {
		return [
			(.init(
				point: .init(latitude: .init(value: 55.759909), longitude: .init(value: 37.618806)),
				zoom: .init(value: 15),
				tilt: .init(value: 15),
				bearing: .init(value: 115)
			), 4, .linear),
			(.init(
				point: .init(latitude: .init(value: 55.759909), longitude: .init(value: 37.618806)),
				zoom: .init(value: 16),
				tilt: .init(value: 15),
				bearing: .init(value: 0)
			), 4, .default),
			(.init(
				point: .init(latitude: .init(value: 55.746962), longitude: .init(value: 37.643073)),
				zoom: .init(value: 16),
				tilt: .init(value: 55),
				bearing: .init(value: 0)
			), 9, .showBothPositions),
			(.init(
				point: .init(latitude: .init(value: 55.746962), longitude: .init(value: 37.643073)),
				zoom: .init(value: 16.5),
				tilt: .init(value: 45),
				bearing: .init(value: 40)
			), 4, .linear),
			(.init(
				point: .init(latitude: .init(value: 55.752425), longitude: .init(value: 37.613983)),
				zoom: .init(value: 16),
				tilt: .init(value: 25),
				bearing: .init(value: 85)
			), 4, .default)
		]
	}()

	init(
		locationManagerFactory: @escaping () -> LocationService?,
		map: Map,
		mapSourceFactory: IMapSourceFactory
	) {
		self.locationManagerFactory = locationManagerFactory
		self.map = map

		let locationSource = mapSourceFactory.makeMyLocationMapObjectSource()
		map.addSource(source: locationSource)

		self.dataLoadingCancellable = self.map.dataLoadingStateChannel.sink { state in
			print(state)
		}
	}

	func testCamera() {
		self.move(at: 0)
	}

	func showCurrentPosition() {
		if self.locationService == nil {
			self.locationService = self.locationManagerFactory()
		}
		self.locationService?.getCurrentPosition { coordinates in
			DispatchQueue.main.async {
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
					).sink { _ in
						print("Move to current location")
					} failure: { error in
						print("Something went wrong: \(error.localizedDescription)")
					}
			}
		}
	}

	private func move(at index: Int) {
		guard index < self.testPoints.count else { return }
		let tuple = self.testPoints[index]
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
				} failure: { error in
					print("Something went wrong: \(error.localizedDescription)")
				}
		}
	}
}
