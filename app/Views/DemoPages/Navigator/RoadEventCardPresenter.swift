import DGis

enum RoadEventCardPresenterOutput {
	case cardCloseRequested
	case roadEventRemoved(RoadEventRemoveResult)
	case roadEventActionCompleted(RoadEventActionResult)
}

protocol RoadEventCardPresenterDelegate: AnyObject {
	func roadEventCardPresenter(
		_ presenter: IRoadEventCardPresenter,
		didRequestToPresent roadEvent: RoadEvent,
		outputCallback: ((RoadEventCardPresenterOutput) -> Void)?
	)
	func roadEventCardPresenterDidRequestToHideRoadEventCard(_ presenter: IRoadEventCardPresenter)
}

extension RoadEventCardPresenterDelegate {
	func roadEventCardPresenterDidRequestToHideRoadEventCard(_ presenter: IRoadEventCardPresenter) {}
}

protocol IRoadEventCardPresenter: AnyObject {
	var delegate: RoadEventCardPresenterDelegate? { get set }

	func showRoadEvent(_ roadEvent: RoadEvent, outputCallback: ((RoadEventCardPresenterOutput) -> Void)?)
	func hideRoadEvent()
}

extension IRoadEventCardPresenter {
	func showRoadEvent(_ roadEvent: RoadEvent) {
		self.showRoadEvent(roadEvent, outputCallback: nil)
	}
}

class RoadEventCardPresenter: IRoadEventCardPresenter {
	weak var delegate: RoadEventCardPresenterDelegate?

	func showRoadEvent(_ roadEvent: RoadEvent, outputCallback: ((RoadEventCardPresenterOutput) -> Void)?) {
		self.delegate?.roadEventCardPresenter(self, didRequestToPresent: roadEvent, outputCallback: outputCallback)
	}

	func hideRoadEvent() {
		self.delegate?.roadEventCardPresenterDidRequestToHideRoadEventCard(self)
	}
}
