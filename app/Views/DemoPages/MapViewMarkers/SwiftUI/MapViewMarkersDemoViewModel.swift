import DGis
import SwiftUI

final class MapViewMarkersDemoViewModel: ObservableObject {
	private enum Constants {
		static let tapRadius = ScreenDistance(value: 1)
	}

	@Published var isErrorAlertShown: Bool = false
	@Published var mapMarkerViewOverlay: MapMarkerViewOverlay
	@Published var showSettings: Bool = false
	@Published var anchor: AnchorPoint = .center
	@Published var offsetX: CGFloat = .zero
	@Published var offsetY: CGFloat = .zero

	private var searchCancellable: Cancellable?
	private let searchManager: SearchManager
	private let map: Map
	private let logger: ILogger
	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	init(
		searchManager: SearchManager,
		map: Map,
		mapMarkerViewOverlay: MapMarkerViewOverlay,
		mapSourceFactory: IMapSourceFactory,
		logger: ILogger
	) {
		self.searchManager = searchManager
		self.map = map
		self.mapMarkerViewOverlay = mapMarkerViewOverlay
		self.logger = logger

		let locationSource = mapSourceFactory.makeMyLocationMapObjectSource(
			bearingSource: .satellite
		)
		self.map.addSource(source: locationSource)
	}

	func tap(objectInfo: RenderedObjectInfo) {
		if let mapObject = objectInfo.item.item as? DgisMapObject {
			self.makeViewMarker(object: mapObject)
		}
	}

	private func makeViewMarker(object: DgisMapObject) {
		self.searchCancellable = self.searchManager.searchByDirectoryObjectId(objectId: object.id).sinkOnMainThread(
			receiveValue: { [weak self] result in
				guard let self, let result, let position = result.markerPosition else { return }
				let markerView = AnyView(ObjectMarkerView(
					title: result.title,
					subtitle: result.subtitle
				))
				let mapMarkerViewModel = DGis.MapMarkerViewModel(
					id: .init(),
					position: position,
					anchor: self.anchor.value,
					offsetX: self.offsetX,
					offsetY: self.offsetY
				)
				var mapMarkerView = DGis.MapMarkerView(
					viewModel: mapMarkerViewModel,
					content: markerView
				)
				mapMarkerView.tapHandler = { self.mapMarkerViewOverlay.remove(mapMarkerView) }
				self.mapMarkerViewOverlay.add(mapMarkerView)
			},
			failure: { [weak self] error in
				guard let self = self else { return }
				self.logger.error("Failed to search for directory object: \(error)")
			}
		)
	}
}
