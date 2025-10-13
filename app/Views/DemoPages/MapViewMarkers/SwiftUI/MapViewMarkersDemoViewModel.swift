import Combine
import DGis
import SwiftUI

@MainActor
final class MapViewMarkersDemoViewModel: ObservableObject, @unchecked Sendable {
	private enum Constants {
		static let tapRadius = ScreenDistance(value: 1)
	}

	@Published var isErrorAlertShown: Bool = false
	@Published var markerOverlayView: MarkerOverlayView
	@Published var showSettings: Bool = false
	@Published var anchor: AnchorPoint = .center
	@Published var offsetX: CGFloat = .zero
	@Published var offsetY: CGFloat = .zero

	private var searchCancellable: ICancellable?
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
		markerOverlayView: MarkerOverlayView,
		mapSourceFactory: IMapSourceFactory,
		logger: ILogger
	) {
		self.searchManager = searchManager
		self.map = map
		self.markerOverlayView = markerOverlayView
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
				Task { @MainActor [weak self] in
					guard let self else { return }
					let markerView = AnyView(ObjectMarkerView(
						title: result.title,
						subtitle: result.subtitle
					))
					let mapMarkerViewModel = DGis.MarkerViewModel(
						id: .init(),
						position: position,
						anchor: self.anchor.value,
						offsetX: self.offsetX,
						offsetY: self.offsetY
					)
					var mapMarkerView = DGis.MarkerView(
						viewModel: mapMarkerViewModel,
						content: markerView
					)
					let markerToRemove = mapMarkerView
					mapMarkerView.tapHandler = { [weak self] in
						Task { @MainActor [weak self] in
							guard let self else { return }
							self.markerOverlayView.remove(markerToRemove)
						}
					}
					self.markerOverlayView.add(mapMarkerView)
				}
			},
			failure: { [weak self] error in
				guard let self else { return }
				Task { @MainActor [weak self] in
					self?.logger.error("Failed to search for directory object: \(error)")
				}
			}
		)
	}
}
