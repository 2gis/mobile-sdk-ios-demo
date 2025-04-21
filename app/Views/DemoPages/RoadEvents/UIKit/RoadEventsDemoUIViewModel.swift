import UIKit
import DGis

protocol RoadEventsDemoUIViewModel: AnyObject {
	func didUpdateRoadEventFormVisibility(_ isVisible: Bool)
	func didUpdateFiltersVisibility(_ isVisible: Bool)
	func didShowAlert(message: String)
}

final class RoadEventsDemoViewModel {
	private enum Constants {
		static let tapRadius = ScreenDistance(value: 5)
	}

	weak var delegate: RoadEventsDemoUIViewModel?

	var visibleEvents: RoadEventDisplayCategoryOptionSet {
		didSet {
			self.roadEventSource.visibleEvents = self.visibleEvents
		}
	}
	
	var isFiltersVisible: Bool = false

	let map: Map
	let roadEventCardPresenter: IRoadEventCardPresenter
	let roadEventFormPresenter: IRoadEventFormPresenter

	private var selectedMarker: Marker?
	private lazy var mapObjectManager: MapObjectManager = MapObjectManager(map: self.map)
	private let roadEventSource: RoadEventSource

	init(
		map: Map,
		mapSourceFactory: IMapSourceFactory,
		roadEventCardPresenter: IRoadEventCardPresenter,
		roadEventFormPresenter: IRoadEventFormPresenter
	) {
		self.map = map
		self.roadEventCardPresenter = roadEventCardPresenter
		self.roadEventFormPresenter = roadEventFormPresenter
		let roadEventSource = mapSourceFactory.makeRoadEventSource()
		self.roadEventSource = roadEventSource
		self.visibleEvents = roadEventSource.visibleEvents

		let locationSource = mapSourceFactory.makeSmoothMyLocationMapObjectSource(
			bearingSource: .satellite
		)
		self.map.addSource(source: locationSource)
		self.map.addSource(source: self.roadEventSource)
	}

	func tap(objectInfo: RenderedObjectInfo) {
		self.hideRoadEvent()

		guard let roadEventMapObject = objectInfo.item.item as? RoadEventMapObject else { return }
		self.handle(roadEventMapObject)
	}

	func createRoadEvent() {
		self.hideRoadEvent()
		self.roadEventFormPresenter.showForm() { [weak self] presenterOutput in
			self?.handle(presenterOutput)
		}
		self.delegate?.didUpdateRoadEventFormVisibility(true)
	}

	func editFilters() {
		self.delegate?.didUpdateFiltersVisibility(true)
	}

	private func hideRoadEventForm() {
		self.roadEventFormPresenter.hideForm()
		self.delegate?.didUpdateRoadEventFormVisibility(false)
	}

	private func handle(_ roadEventMapObject: RoadEventMapObject) {
		let roadEventId = roadEventMapObject.id
		let isHighlighted = self.roadEventSource.highlightedObjects.contains(roadEventId)
		self.roadEventSource.setHighlighted(directoryObjectIds: [roadEventId], highlighted: !isHighlighted)
		self.roadEventCardPresenter.showRoadEvent(
			roadEventMapObject.event,
			outputCallback: { [weak self] presenterOutput in
				self?.handle(presenterOutput)
		})
	}

	private func handle(_ output: RoadEventFormPresenterOutput) {
		switch output {
			case .roadEventCreationRequestFinished(let result):
				switch result {
					case .success(let result):
						switch result {
							case .event:
								self.showMessage("Added new event!")
								self.hideRoadEventForm()
							case .error(let error):
								self.showMessage("Can't add new event: \(error)")
						@unknown default:
							assertionFailure("Unsupported Event \(self)")
							return
						}
					case .failure(let error):
						self.showCommonError(error)
				}
			case .roadEventCreationCancelled:
				self.hideRoadEventForm()
		}
	}

	private func handle(_ output: RoadEventCardPresenterOutput) {
		switch output {
			case .cardCloseRequested:
				self.roadEventCardPresenter.hideRoadEvent()
			case .roadEventRemoved(let result):
				switch result {
					case .success(let actionResult):
						switch actionResult {
							case .ok:
								self.showMessage("Road event was deleted!")
								self.roadEventCardPresenter.hideRoadEvent()
							case .networkError:
								self.showNetworkError()
						@unknown default: break
						}
					case .failure(let error):
						self.showCommonError(error)
				}
			case .roadEventActionCompleted(let result):
				switch result {
					case .success((_, let actionResult)):
						switch actionResult {
							case .ok:
								self.showMessage("Thank you!")
								self.roadEventCardPresenter.hideRoadEvent()
							case .networkError:
								self.showNetworkError()
						@unknown default: break
						}
					case .failure(let error):
						self.showCommonError(error)
				}
		}
	}

	private func hideRoadEvent() {
		self.roadEventCardPresenter.hideRoadEvent()
	}

	private func showNetworkError() {
		self.showMessage("Network error.")
	}

	private func showCommonError(_ error: Error) {
		self.showMessage("Something went wrong: \(error)")
	}

	private func showMessage(_ message: String) {
		self.delegate?.didShowAlert(message: message)
	}
}
