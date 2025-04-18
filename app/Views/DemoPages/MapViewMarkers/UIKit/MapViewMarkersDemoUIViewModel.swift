import DGis
import UIKit

final class MapViewMarkersDemoUIViewModel: ObservableObject {
	var selectedMapObject: MapObjectCardViewModel?

	private var searchCancellable: Cancellable?
	private let searchManager: SearchManager
	let mapMarkerPresenter: MapMarkerPresenter
	private let map: Map
	private let logger: ILogger

	init(
		searchManager: SearchManager,
		map: Map,
		mapMarkerPresenter: MapMarkerPresenter,
		mapSourceFactory: IMapSourceFactory,
		logger: ILogger
	) {
		self.searchManager = searchManager
		self.map = map
		self.logger = logger
		self.mapMarkerPresenter = mapMarkerPresenter

		let locationSource = mapSourceFactory.makeMyLocationMapObjectSource(
			bearingSource: .satellite
		)
		self.map.addSource(source: locationSource)
	}

	func tap(objectInfo: RenderedObjectInfo) {
		self.selectedMapObject = MapObjectCardViewModel(
			objectInfo: objectInfo,
			searchManager: self.searchManager,
			logger: self.logger,
			onClose: {
				[weak self] in
				self?.hideSelectedMarker()
			}
		)
		if let selectedMapObject {
			self.mapMarkerPresenter.showMarkerView(viewModel: selectedMapObject)
		}
	}

	private func hideSelectedMarker() {
		self.selectedMapObject = nil
	}
}
