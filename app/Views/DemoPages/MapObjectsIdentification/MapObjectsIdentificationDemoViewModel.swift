import SwiftUI
import Combine
import DGis

final class MapObjectsIdentificationDemoViewModel: ObservableObject {
	private enum Constants {
		static let tapRadius = ScreenDistance(value: 5)
	}

	@Published var selectedMapObject: MapObjectCardViewModel?

	let mapMarkerPresenter: MapMarkerPresenter

	private let searchManagerFactory: () -> SearchManager
	private let imageFactory: () -> IImageFactory
	private let map: Map
	private let toMap: CGAffineTransform
	private var getRenderedObjectsCancellable: DGis.Cancellable?
	private var selectedMarker: Marker?
	private lazy var mapObjectManager: MapObjectManager = MapObjectManager(map: self.map)
	private lazy var selectedMarkerIcon: DGis.Image = {
		let factory = self.imageFactory()
		let icon = UIImage(systemName: "mappin.and.ellipse")!
			.withTintColor(#colorLiteral(red: 0.2470588235, green: 0.6, blue: 0.1607843137, alpha: 1))
			.withConfiguration(UIImage.SymbolConfiguration(scale: .large))
		return factory.make(image: icon)
	}()

	init(
		searchManagerFactory: @escaping () -> SearchManager,
		imageFactory: @escaping () -> IImageFactory,
		mapMarkerPresenter: MapMarkerPresenter,
		map: Map,
		mapSourceFactory: IMapSourceFactory
	) {
		self.searchManagerFactory = searchManagerFactory
		self.imageFactory = imageFactory
		self.mapMarkerPresenter = mapMarkerPresenter
		self.map = map

		let locationSource = mapSourceFactory.makeSmoothMyLocationMapObjectSource(
			directionBehaviour: .followSatelliteHeading
		)
		self.map.addSource(source: locationSource)
		self.map.addSource(source: mapSourceFactory.makeRoadEventSource())

		let scale = UIScreen.main.nativeScale
		self.toMap = CGAffineTransform(scaleX: scale, y: scale)
	}

	func tap(_ location: CGPoint) {
		let mapLocation = location.applying(self.toMap)
		let tapPoint = ScreenPoint(x: Float(mapLocation.x), y: Float(mapLocation.y))
		self.tap(point: tapPoint, tapRadius: Constants.tapRadius)
	}

	/// - Parameter point: A tap point in *pixel* (native scale) coordinates.
	/// - Parameter tapRadius: Radius around tap point in which objects will
	///   be detected.
	private func tap(point: ScreenPoint, tapRadius: ScreenDistance) {
		self.hideSelectedMarker()
		self.getRenderedObjectsCancellable?.cancel()

		let cancel = self.map.getRenderedObjects(centerPoint: point, radius: tapRadius).sink(
			receiveValue: {
				infos in
				// The first object is the closest one to the tapped point.
				guard let info = infos.first else { return }
				DispatchQueue.main.async {
					[weak self] in
					self?.handle(selectedObject: info)
				}
			},
			failure: { error in
				print("Failed to fetch objects: \(error)")
			}
		)
		self.getRenderedObjectsCancellable = cancel
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
			icon: self.selectedMarkerIcon
		)
		let marker = Marker(options: markerOptions)
		self.mapObjectManager.addObject(item: marker)
		self.selectedMarker = marker

		self.selectedMapObject = MapObjectCardViewModel(
			objectInfo: selectedObject,
			searchManagerFactory: searchManagerFactory,
			onClose: {
				[weak self] in
				self?.hideSelectedMarker()
			}
		)

		self.mapMarkerPresenter.showMarkerView(viewModel: self.selectedMapObject!)
	}
}

