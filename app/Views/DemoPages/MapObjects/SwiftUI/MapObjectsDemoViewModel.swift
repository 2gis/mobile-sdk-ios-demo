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
			imageFactory: self.imageFactory,
			logger: self.logger
		)
		self.viewModels.append(viewModel)
		return viewModel
	}()

	lazy var modelViewModel = {
		let viewModel = ModelViewModel(
			map: self.map,
			modelFactory: self.modelFactory,
			logger: self.logger
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
	private let logger: ILogger
	private var viewModels: [IMapObjectViewModel] = []

	init(
		map: Map,
		mapSourceFactory: IMapSourceFactory,
		imageFactory: IImageFactory,
		modelFactory: IModelFactory,
		logger: ILogger
	) {
		self.map = map
		self.imageFactory = imageFactory
		self.modelFactory = modelFactory
		self.logger = logger

		let locationSource = mapSourceFactory.makeSmoothMyLocationMapObjectSource(
			bearingSource: .satellite
		)
		self.map.addSource(source: locationSource)
	}

	func tap(objectInfo: RenderedObjectInfo) {
		self.handle(selectedObject: objectInfo)
	}

	func removeAll() {
		self.viewModels.forEach { $0.removeAll() }
	}

	private func handle(selectedObject: RenderedObjectInfo) {
		self.selectedMapObject = RenderedObjectInfoViewModel(
			objectInfo: selectedObject,
			onClose: {
				[weak self] in
				self?.selectedMapObject = nil
			}
		)
	}
}

