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
	private let roadEventCardPresenter: IRoadEventCardPresenter
	private let roadEventFormPresenter: IRoadEventFormPresenter
	private let roadEventCardViewFactory: IRoadEventCardViewFactory

	init(
		map: Map,
		roadEventCardPresenter: IRoadEventCardPresenter,
		roadEventFormPresenter: IRoadEventFormPresenter,
		roadEventCardViewFactory: IRoadEventCardViewFactory
	) {
		self.map = map
		self.roadEventCardPresenter = roadEventCardPresenter
		self.roadEventFormPresenter = roadEventFormPresenter
		self.roadEventCardViewFactory = roadEventCardViewFactory
	}

	func makeOverlayView() -> IMapOverlayView {
		RoadEventsMapOverlayUIView(
			map: self.map,
			roadEventCardPresenter: self.roadEventCardPresenter,
			roadEventFormPresenter: self.roadEventFormPresenter,
			roadEventCardViewFactory: self.roadEventCardViewFactory
		)
	}
}
