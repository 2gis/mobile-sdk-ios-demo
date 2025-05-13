import UIKit
import DGis

protocol IMapOverlayView: UIView {
	var visibleAreaEdgeInsets: UIEdgeInsets { get }
	var visibleAreaEdgeInsetsChangedCallback: ((UIEdgeInsets) -> Void)? { get set }
}

protocol IMapViewOverlayFactory {
	func makeOverlayView() -> IMapOverlayView
}

class RoadEventsMapOverlayFactory: IMapViewOverlayFactory {
	private let map: Map
	private let roadEventFormPresenter: IRoadEventFormPresenter
	private let roadEventCardViewFactory: IRoadEventCardViewFactory

	init(
		map: Map,
		roadEventFormPresenter: IRoadEventFormPresenter,
		roadEventCardViewFactory: IRoadEventCardViewFactory
	) {
		self.map = map
		self.roadEventFormPresenter = roadEventFormPresenter
		self.roadEventCardViewFactory = roadEventCardViewFactory
	}

	func makeOverlayView() -> IMapOverlayView {
		RoadEventsMapOverlayView(
			map: self.map,
			roadEventFormPresenter: self.roadEventFormPresenter,
			roadEventCardViewFactory: self.roadEventCardViewFactory
		)
	}
}
