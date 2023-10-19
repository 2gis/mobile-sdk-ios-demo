import SwiftUI
import Combine
import DGis

final class MapObjectsDemoViewModel: ObservableObject {
	@Published var mapObjectType: MapObjectType = .marker
	@Published var showObjects: Bool = false
	private let map: Map
	private let imageFactory: IImageFactory
	private lazy var mapObjectManager = MapObjectManager(map: self.map)

	init(
		map: Map,
		imageFactory: IImageFactory
	) {
		self.map = map
		self.imageFactory = imageFactory
	}

	func makeCircleViewModel() -> CircleViewModel {
		CircleViewModel(
			map: self.map,
			mapObjectManager: self.mapObjectManager
		)
	}

	func makeMarkerViewModel() -> MarkerViewModel {
		MarkerViewModel(
			map: self.map,
			mapObjectManager: self.mapObjectManager,
			imageFactory: self.imageFactory
		)
	}

	func makePolygonViewModel() -> PolygonViewModel {
		PolygonViewModel(
			map: self.map,
			mapObjectManager: self.mapObjectManager
		)
	}

	func makePolylineViewModel() -> PolylineViewModel {
		PolylineViewModel(
			map: self.map,
			mapObjectManager: self.mapObjectManager
		)
	}

	func removeAll() {
		self.mapObjectManager.removeAll()
	}
}

