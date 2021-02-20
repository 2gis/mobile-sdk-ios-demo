import SwiftUI
import PlatformSDK

final class RootViewModel {
	private static let tapRadius: CGFloat = 5

	let searchStore: SearchStore

	private let searchManagerFactory: () -> ISearchManager
	private let sourceFactory: () -> ISourceFactory
	private let locationManagerFactory: () -> LocationService?
	private let map: Map
	private let toMap: CGAffineTransform
	private var locationService: LocationService?

	private var moveCameraCancellable: Cancellable?
	private var getRenderedObjectsCancellable: Cancellable?

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
		searchManagerFactory: @escaping () -> ISearchManager,
		sourceFactory: @escaping () -> ISourceFactory,
		locationManagerFactory: @escaping () -> LocationService?,
		map: Map
	) {
		self.searchManagerFactory = searchManagerFactory
		self.sourceFactory = sourceFactory
		self.locationManagerFactory = locationManagerFactory
		self.map = map

		let scale = UIScreen.main.nativeScale
		self.toMap = CGAffineTransform(scaleX: scale, y: scale)

		let service = SearchService(
			searchManagerFactory: self.searchManagerFactory,
			scheduler: DispatchQueue.main
		)
		let reducer = SearchReducer(service: service)
		self.searchStore = SearchStore(initialState: .init(), reducer: reducer)
	}

	func makeSearchViewModel() -> SearchViewModel {
		let service = SearchService(
			searchManagerFactory: self.searchManagerFactory,
			scheduler: DispatchQueue.main
		)
		let viewModel = SearchViewModel(
			searchStore: self.searchStore,
			searchService: service
		)
		return viewModel
	}

	func testCamera() {
		self.move(at: 0)
	}

	func showCurrentPosition() {
		if self.locationService == nil {
			self.locationService = self.locationManagerFactory()
		}
		self.locationService?.getCurrentPosition { (coordinates) in
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

	func tap(_ location: CGPoint) {
		let mapLocation = location.applying(self.toMap)
		let tapPoint = ScreenPoint(x: Float(mapLocation.x), y: Float(mapLocation.y))
		let tapRadius = ScreenDistance(value: Float(Self.tapRadius))
		let cancel = self.map.getRenderedObjects(centerPoint: tapPoint, radius: tapRadius)
			.sink(receiveValue: { infos in
				// Достаточно взять первый маркер. В данном примере перечислим все
				// маркера в окрестности.
				for info in infos {
					if let object = info.item.item {
						print("Tapped object: \(object).")
					}
				}
			},
			failure: { error in
				print("Failed to fetch objects: \(error)")
			})
		self.getRenderedObjectsCancellable = cancel
	}
}
