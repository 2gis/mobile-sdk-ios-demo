import DGis

protocol RoadEventFormPresenterDelegate: AnyObject {
	func roadEventFormPresenterDidRequestToShowForm(
		_ presenter: IRoadEventFormPresenter,
		completion: @escaping (RoadEventFormPresenterOutput) -> Void
	)

	func roadEventBuilderDidRequestToShowHideForm(_ presenter: IRoadEventFormPresenter)
}

enum RoadEventFormPresenterOutput {
	case roadEventCreationCancelled
	case roadEventCreationRequestFinished(CreateRoadEventResult)
}

protocol IRoadEventFormPresenter {
	var delegate: RoadEventFormPresenterDelegate? { get set }

	func showForm(_ completion: @escaping (RoadEventFormPresenterOutput) -> Void)
	func hideForm()
}

extension IRoadEventFormPresenter {
	func showForm(_ completion: @escaping (RoadEventFormPresenterOutput) -> Void) {
		self.delegate?.roadEventFormPresenterDidRequestToShowForm(self, completion: completion)
	}

	func hideForm() {
		self.delegate?.roadEventBuilderDidRequestToShowHideForm(self)
	}
}

class RoadEventFormPresenter: IRoadEventFormPresenter {
	weak var delegate: RoadEventFormPresenterDelegate?
}
