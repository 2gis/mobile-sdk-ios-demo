import SwiftUI
import Combine
import DGis

final class MapObjectsIdentificationDemoViewModel: ObservableObject {
	private enum Constants {
		static let tapRadius = ScreenDistance(value: 5)
	}

	@Published var selectedMapObject: MapObjectCardViewModel?

	let mapMarkerPresenter: MapMarkerPresenter

	private let searchManager: SearchManager
	private let imageFactory: IImageFactory
	private let map: Map
	private let dgisSource: DgisSource?
	private var selectedMarker: Marker?
	private lazy var mapObjectManager: MapObjectManager = MapObjectManager(map: self.map)
	private lazy var selectedMarkerIcon: DGis.Image = {
		let icon = UIImage(systemName: "mappin.and.ellipse")!
			.withTintColor(#colorLiteral(red: 0.2470588235, green: 0.6, blue: 0.1607843137, alpha: 1))
			.withConfiguration(UIImage.SymbolConfiguration(scale: .large))
		return self.imageFactory.make(image: icon)
	}()

	init(
		searchManager: SearchManager,
		imageFactory: IImageFactory,
		mapMarkerPresenter: MapMarkerPresenter,
		map: Map,
		mapSourceFactory: IMapSourceFactory
	) {
		self.searchManager = searchManager
		self.imageFactory = imageFactory
		self.mapMarkerPresenter = mapMarkerPresenter
		self.map = map
		self.dgisSource = self.map.sources.first(where: { $0 is DgisSource }) as? DgisSource

		let locationSource = mapSourceFactory.makeSmoothMyLocationMapObjectSource(
			directionBehaviour: .followSatelliteHeading
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
		self.selectedMapObject?.hideObjects()
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
			icon: self.selectedMarkerIcon
		)
		let marker = Marker(options: markerOptions)
		self.mapObjectManager.addObject(item: marker)
		self.selectedMarker = marker

		self.selectedMapObject = MapObjectCardViewModel(
			objectInfo: selectedObject,
			searchManager: self.searchManager,
			dgisSource: self.dgisSource,
			onClose: {
				[weak self] in
				self?.hideSelectedMarker()
			}
		)

		self.mapMarkerPresenter.showMarkerView(viewModel: self.selectedMapObject!)
	}
}
