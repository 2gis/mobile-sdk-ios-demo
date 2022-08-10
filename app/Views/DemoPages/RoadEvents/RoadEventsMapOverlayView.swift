import UIKit
import DGis

class RoadEventsMapOverlayView: UIView, IMapOverlayView {
	var visibleAreaEdgeInsets: UIEdgeInsets {
		var insets: UIEdgeInsets = .zero
		if let createRoadEventView = self.createRoadEventView {
			insets = createRoadEventView.visibleAreaEdgeInsets
		} else if let roadEventCardView = self.roadEventCardView {
			insets.bottom = roadEventCardView.frame.height
		}
		return insets
	}

	var visibleAreaEdgeInsetsChangedCallback: ((UIEdgeInsets) -> Void)?

	private let map: Map
	private let roadEventCardPresenter: IRoadEventCardPresenter
	private var roadEventFormPresenter: IRoadEventFormPresenter
	private let roadEventCardViewFactory: IRoadEventCardViewFactory

	private var roadEventCardView: IRoadEventCardView?
	private var createRoadEventView: ICreateRoadEventView?

	init(
		frame: CGRect = .zero,
		map: Map,
		roadEventCardPresenter: IRoadEventCardPresenter,
		roadEventFormPresenter: IRoadEventFormPresenter,
		roadEventCardViewFactory: IRoadEventCardViewFactory
	) {
		self.map = map
		self.roadEventCardPresenter = roadEventCardPresenter
		self.roadEventFormPresenter = roadEventFormPresenter
		self.roadEventCardViewFactory = roadEventCardViewFactory
		super.init(frame: frame)

		self.setup()
	}

	required init?(coder: NSCoder) {
		fatalError("Use init(frame:map:roadEventCardPresenter:...)")
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		self.updateCameraPaddings()
	}

	override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
		let resultView = super.hitTest(point, with: event)
		if resultView == self {
			return nil
		}
		return resultView
	}

	override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
		let hitRect = self.bounds
		return hitRect.contains(point)
	}

	private func setup() {
		self.roadEventCardPresenter.delegate = self
		self.roadEventFormPresenter.delegate = self
	}

	private func show(_ roadEvent: RoadEvent, outputCallback: ((RoadEventCardPresenterOutput) -> Void)?) {
		if let cardView = self.roadEventCardView {
			cardView.setRoadEvent(roadEvent)
		} else {
			let cardView = self.roadEventCardViewFactory.makeRoadEventCardView(roadEvent)
			cardView.translatesAutoresizingMaskIntoConstraints = false
			self.addSubview(cardView)
			NSLayoutConstraint.activate([
				cardView.topAnchor.constraint(greaterThanOrEqualTo: self.safeAreaLayoutGuide.topAnchor),
				cardView.leftAnchor.constraint(equalTo: self.leftAnchor),
				cardView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
				cardView.rightAnchor.constraint(equalTo: self.rightAnchor)
			])
			self.roadEventCardView = cardView
			cardView.closeButtonCallback = {
				outputCallback?(.cardCloseRequested)
			}
			cardView.roadEventActionResultCallback = { result in
				outputCallback?(.roadEventActionCompleted(result))
			}
			cardView.removeRoadEventActionResultCallback = { result in
				outputCallback?(.roadEventRemoved(result))
			}
		}
	}

	private func hideRoadEventCard() {
		guard let cardView = self.roadEventCardView else { return }
		cardView.removeFromSuperview()
		self.roadEventCardView = nil
	}

	private func showRoadEventForm(completion: @escaping (RoadEventFormPresenterOutput) -> Void) {
		guard self.createRoadEventView == nil else { return }
		let createRoadEventView = self.roadEventCardViewFactory.makeCreateRoadEventView(map: self.map)
		createRoadEventView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(createRoadEventView)
		NSLayoutConstraint.activate([
			createRoadEventView.topAnchor.constraint(equalTo: self.topAnchor),
			createRoadEventView.leftAnchor.constraint(equalTo: self.leftAnchor),
			createRoadEventView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			createRoadEventView.rightAnchor.constraint(equalTo: self.rightAnchor)
		])
		self.createRoadEventView = createRoadEventView
		createRoadEventView.cancelButtonCallback = {
			completion(.roadEventCreationCancelled)
		}
		createRoadEventView.createRoadEventRequestCallback = { result in
			completion(.roadEventCreationRequestFinished(result))
		}
		createRoadEventView.visibleAreaEdgeInsetsChangedCallback = { [weak self] insets in
			self?.updateCameraPaddings()
		}
	}

	private func updateCameraPaddings() {
		// Пересчитываем отступы камеры на основании видимой области карты.
		// Операция нужна для корректного позиционирования создаваемого дорожного события,
		// так как для размещения события используется точка местности,
		// которая находится в точке позиции камеры (`map.camera.position.point`).
		guard let scale = self.window?.screen.nativeScale else { return }
		var insets: UIEdgeInsets = .zero
		if let createRoadEventView = self.createRoadEventView {
			insets = createRoadEventView.visibleAreaEdgeInsets
		} else if let roadEventCardView = self.roadEventCardView {
			insets.bottom = roadEventCardView.frame.height
		}
		let padding = Padding(
			left: UInt32(insets.left * scale),
			top: UInt32(insets.top * scale),
			right: UInt32(insets.right * scale),
			bottom: UInt32(insets.bottom * scale)
		)
		self.map.camera.setPadding(padding: padding)
	}

	private func hideRoadEventForm() {
		guard let createRoadEventView = self.createRoadEventView else { return }
		createRoadEventView.removeFromSuperview()
		self.createRoadEventView = nil
	}
}

extension RoadEventsMapOverlayView: RoadEventCardPresenterDelegate {
	func roadEventCardPresenter(
		_ presenter: IRoadEventCardPresenter,
		didRequestToPresent roadEvent: RoadEvent,
		outputCallback: ((RoadEventCardPresenterOutput) -> Void)?
	) {
		self.show(roadEvent, outputCallback: outputCallback)
	}

	func roadEventCardPresenterDidRequestToHideRoadEventCard(_ presenter: IRoadEventCardPresenter) {
		self.hideRoadEventCard()
	}
}

extension RoadEventsMapOverlayView: RoadEventFormPresenterDelegate {
	func roadEventBuilderDidRequestToShowHideForm(_ presenter: IRoadEventFormPresenter) {
		self.hideRoadEventForm()
	}

	func roadEventFormPresenterDidRequestToShowForm(
		_ presenter: IRoadEventFormPresenter,
		completion: @escaping (RoadEventFormPresenterOutput) -> Void
	) {
		self.showRoadEventForm(completion: completion)
	}
}
