import SwiftUI
import Combine
import DGis

final class MapObjectsDemoViewModel: ObservableObject {
	@Published var mapObjectType: MapObjectType = .marker
	@Published var showObjects: Bool = false
	private let map: Map
	private let imageFactory: IImageFactory
	private let modelFactory: IModelFactory
	private lazy var mapObjectManager = MapObjectManager(map: self.map)

	init(
		map: Map,
		imageFactory: IImageFactory,
		modelFactory: IModelFactory
	) {
		self.map = map
		self.imageFactory = imageFactory
		self.modelFactory = modelFactory
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

	func makeModelViewModel() -> ModelViewModel {
		ModelViewModel(
			map: self.map,
			modelFactory: self.modelFactory
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

