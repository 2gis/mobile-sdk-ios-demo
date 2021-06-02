import SwiftUI
import Combine
import PlatformSDK

final class MarkersDemoViewModel: ObservableObject {
	private enum Constants {
		static let tapRadius = ScreenDistance(value: 5)
	}

	@Published var showMarkers: Bool = false
	@Published var selectedObjectCardViewModel: MapObjectCardViewModel?
	let markerViewModel: MarkerViewModel

	private let searchManagerFactory: () -> SearchManager
	private let map: Map
	private let toMap: CGAffineTransform
	private var getRenderedObjectsCancellable: PlatformSDK.Cancellable?

	init(
		map: Map,
		imageFactory: IImageFactory,
		searchManagerFactory: @escaping () -> SearchManager
	) {
		self.searchManagerFactory = searchManagerFactory
		self.map = map
		let scale = UIScreen.main.nativeScale
		self.toMap = CGAffineTransform(scaleX: scale, y: scale)

		self.markerViewModel =  MarkerViewModel(
			map: map,
			imageFactory: imageFactory
		)
	}

	func tap(_ location: CGPoint) {
		let mapLocation = location.applying(self.toMap)
		let tapPoint = ScreenPoint(x: Float(mapLocation.x), y: Float(mapLocation.y))
		self.tap(point: tapPoint, tapRadius: Constants.tapRadius)
	}

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
		self.selectedObjectCardViewModel = nil
	}

	private func handle(selectedObject: RenderedObjectInfo) {
		self.selectedObjectCardViewModel = MapObjectCardViewModel(
			objectInfo: selectedObject,
			searchManagerFactory: searchManagerFactory,
			onClose: {
				[weak self] in
				self?.hideSelectedMarker()
			}
		)
	}
}

