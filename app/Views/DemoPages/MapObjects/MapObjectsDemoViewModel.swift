import SwiftUI
import Combine
import DGis

final class MapObjectsDemoViewModel: ObservableObject {
	@Published var mapObjectType: MapObjectType = .marker
	@Published var showObjects: Bool = false
	@Published var selectedMapObject: RenderedObjectInfoViewModel?

	lazy var circleViewModel = {
		let viewModel = CircleViewModel(map: self.map)
		self.viewModels.append(viewModel)
		return viewModel
	}()

	lazy var markerViewModel = {
		let viewModel = MarkerViewModel(
			map: self.map,
			imageFactory: self.imageFactory
		)
		self.viewModels.append(viewModel)
		return viewModel
	}()

	lazy var modelViewModel = {
		let viewModel = ModelViewModel(
			map: self.map,
			modelFactory: self.modelFactory
		)
		self.viewModels.append(viewModel)
		return viewModel
	}()

	lazy var polygonViewModel = {
		let viewModel = PolygonViewModel(map: self.map)
		self.viewModels.append(viewModel)
		return viewModel
	}()

	lazy var polylineViewModel = {
		let viewModel = PolylineViewModel(map: self.map)
		self.viewModels.append(viewModel)
		return viewModel
	}()

	private let map: Map
	private let imageFactory: IImageFactory
	private let modelFactory: IModelFactory
	private var viewModels: [IMapObjectViewModel] = []

	init(
		map: Map,
		mapSourceFactory: IMapSourceFactory,
		imageFactory: IImageFactory,
		modelFactory: IModelFactory
	) {
		self.map = map
		self.imageFactory = imageFactory
		self.modelFactory = modelFactory

		let locationSource = mapSourceFactory.makeMyLocationMapObjectSource()
		map.addSource(source: locationSource)
	}

	func tap(objectInfo: RenderedObjectInfo) {
		self.handle(selectedObject: objectInfo)
	}

	func removeAll() {
		self.viewModels.forEach { $0.removeAll() }
	}

	private func handle(selectedObject: RenderedObjectInfo) {
		guard
			selectedObject.item.item as? SimpleMapObject != nil
		else {
			return
		}
		self.selectedMapObject = RenderedObjectInfoViewModel(
			objectInfo: selectedObject,
			onClose: {
				[weak self] in
				self?.selectedMapObject = nil
			}
		)
	}
}

