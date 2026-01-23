import Combine
import DGis
import SwiftUI

@MainActor
final class MapGestureSettingsDemoViewModel: ObservableObject, @unchecked Sendable {
	@Published var mapGestureType: MapGestureType = .mapRecognizer
	@Published var showSettings: Bool = false
	@Published var targetGeoPoint: GeoPointWithElevation? {
		didSet {
			if self.targetGeoPoint != oldValue {
				self.mapObjectManager.removeAll()
				if let geoPoint = self.targetGeoPoint {
					self.makeMarker(position: geoPoint).map { self.mapObjectManager.addObject(item: $0) }
				}
			}
		}
	}

	@Published var mapGestureViewOptions: MapGestureViewOptions = .default
	@Published var mapGestureUIView: UIView & IMapGestureUIView

	private let mapFactory: IMapFactory
	private let imageFactory: IImageFactory

	private lazy var selectedMarker = self.imageFactory.make(
		image: UIImage(named: "svg/marker_search_selected_2")!
	)

	private lazy var mapObjectManager: MapObjectManager = .init(map: self.mapFactory.map)

	init(
		mapFactory: IMapFactory,
		imageFactory: IImageFactory
	) {
		self.mapFactory = mapFactory
		self.imageFactory = imageFactory
		self.mapGestureUIView = MapGestureType.mapRecognizer.makeMapGestureUIViewFactory(options: .default).makeGestureUIView(
			map: mapFactory.map,
			eventProcessor: mapFactory.mapEventProcessor,
			coordinateSpace: mapFactory.mapCoordinateSpace
		)
	}

	func longPress(_ objectInfo: RenderedObjectInfo) {
		self.targetGeoPoint = objectInfo.closestMapPoint
	}

	func nextMapGestureType() {
		self.mapGestureType.next()
		self.mapGestureUIView = self.makeMapGestureUIViewFactory().makeGestureUIView(
			map: self.mapFactory.map,
			eventProcessor: self.mapFactory.mapEventProcessor,
			coordinateSpace: self.mapFactory.mapCoordinateSpace
		)
	}

	private func makeMapGestureUIViewFactory() -> IMapGestureUIViewFactory {
		self.mapGestureType.makeMapGestureUIViewFactory(options: self.mapGestureViewOptions)
	}

	private func makeMarker(
		position: GeoPointWithElevation
	) -> Marker? {
		let options = MarkerOptions(
			position: position,
			icon: self.selectedMarker
		)
		do {
			return try Marker(options: options)
		} catch {
			return nil
		}
	}
}
