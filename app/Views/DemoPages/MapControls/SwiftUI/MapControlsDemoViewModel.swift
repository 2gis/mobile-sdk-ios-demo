import Combine
import DGis
import SwiftUI

final class MapControlsDemoViewModel: ObservableObject, @unchecked Sendable {
	private enum Constants {
		static let tapRadius = ScreenDistance(value: 1)
	}

	@Published var selectedMapObject: MapObjectCardViewModel?
	@Published var isErrorAlertShown: Bool = false

	private let searchManager: SearchManager
	private let imageFactory: IImageFactory
	private let map: Map
	private let dgisSource: DgisSource?
	private let logger: ILogger
	private var selectedMarker: Marker?
	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	private lazy var mapObjectManager: MapObjectManager = .init(map: self.map)
	private lazy var selectedMarkerIcon: DGis.Image = {
		let icon = UIImage(named: "svg/marker_pin")!
		return self.imageFactory.make(image: icon)
	}()

	init(
		searchManager: SearchManager,
		imageFactory: IImageFactory,
		map: Map,
		mapSourceFactory: IMapSourceFactory,
		logger: ILogger
	) {
		self.searchManager = searchManager
		self.imageFactory = imageFactory
		self.map = map
		self.dgisSource = self.map.sources.first(where: { $0 is DgisSource }) as? DgisSource
		self.logger = logger

		let locationSource = mapSourceFactory.makeMyLocationMapObjectSource(
			bearingSource: .satellite
		)
		self.map.addSource(source: locationSource)
		self.map.addSource(source: mapSourceFactory.makeRoadEventSource())
	}

	func tap(objectInfo: RenderedObjectInfo) {
		self.hideSelectedMarker()
		self.handle(selectedObject: objectInfo)
	}

	private func hideSelectedMarker() {
		if let marker = self.selectedMarker {
			self.mapObjectManager.removeObject(item: marker)
		}
		self.selectedMapObject = nil
	}

	private func handle(selectedObject: RenderedObjectInfo) {
		let mapPoint = selectedObject.closestMapPoint
		let markerPoint = GeoPointWithElevation(
			latitude: mapPoint.latitude,
			longitude: mapPoint.longitude
		)
		let markerOptions = MarkerOptions(
			position: markerPoint,
			icon: self.selectedMarkerIcon,
			anchor: Anchor(x: 0.5, y: 1.0)
		)
		let marker: Marker
		do {
			marker = try Marker(options: markerOptions)
		} catch let error as SimpleError {
			self.errorMessage = error.description
			return
		} catch {
			self.errorMessage = error.localizedDescription
			return
		}
		self.mapObjectManager.addObject(item: marker)
		self.selectedMarker = marker

		self.selectedMapObject = MapObjectCardViewModel(
			objectInfo: selectedObject,
			searchManager: self.searchManager,
			logger: self.logger,
			onClose: {
				[weak self] in
				self?.hideSelectedMarker()
			}
		)
	}
}
