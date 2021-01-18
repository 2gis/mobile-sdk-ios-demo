import SwiftUI
import PlatformSDK

final class RootViewModel {

	let searchStore: SearchStore

	private let searchManagerFactory: () -> ISearchManager
	private let map: Map

	private var moveCameraCancellable: Cancellable?
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
		map: Map
	) {
		self.searchManagerFactory = searchManagerFactory
		self.map = map

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

	private func move(at index: Int) {

		guard index < self.testPoints.count else { return }
		let tuple = self.testPoints[index]
		DispatchQueue.main.async {
			self.moveCameraCancellable?.cancel()
			self.moveCameraCancellable = self.map
				.camera()
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
