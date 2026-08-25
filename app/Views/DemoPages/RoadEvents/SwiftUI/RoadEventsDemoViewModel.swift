import Combine
import DGis
import SwiftUI

final class RoadEventsDemoViewModel: ObservableObject, @unchecked Sendable {
	private enum Constants {
		static let tapRadius = ScreenDistance(value: 5)
	}

	@Published var isRoadEventFormPresented: Bool = false
	@Published var selectedRoadEvent: RoadEvent?
	@Published var isAlertShowing: Bool = false
	@Published var isFiltersShown: Bool = false
	@Published var visibleEvents: RoadEventDisplayCategoryOptionSet {
		didSet {
			self.roadEventSource.visibleEvents = self.visibleEvents
		}
	}

	private(set) var alertMessage: String?

	let map: Map

	private var selectedMarker: Marker?
	private lazy var mapObjectManager: MapObjectManager = .init(map: self.map)
	private let roadEventSource: RoadEventSource

	init(
		map: Map,
		mapSourceFactory: IMapSourceFactory
	) {
		self.map = map
		let roadEventSource = mapSourceFactory.makeRoadEventSource()
		self.roadEventSource = roadEventSource
		self.visibleEvents = roadEventSource.visibleEvents

		let locationSource = mapSourceFactory.makeMyLocationMapObjectSource(bearingSource: .auto)
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
		self.isRoadEventFormPresented = true
	}

	func editFilters() {
		self.isFiltersShown = true
	}

	func handle(_ result: CreateRoadEventResult) {
		switch result {
		case let .success(result):
			switch result {
			case .event:
				self.showMessage("Added a new event!")
			case let .error(error):
				self.showMessage("Failed to create an event: \(error)")
			@unknown default:
				assertionFailure("Unknown value for AddEventResult")
			}
		case let .failure(error):
			self.showCommonError(error)
		@unknown default:
			assertionFailure("Unknown value for CreateRoadEventResult")
		}
		self.hideRoadEventForm()
	}

	func handle(_ result: RoadEventActionResult) {
		self.hideRoadEvent()

		switch result {
		case let .success((_, actionResult)):
			switch actionResult {
			case .ok:
				self.showMessage("Thanks!")
			case .networkError:
				self.showNetworkError()
			@unknown default:
				assertionFailure("Unknown value for ActionResult")
			}
		case let .failure(error):
			self.showCommonError(error)
		@unknown default:
			assertionFailure("Unknown value for RoadEventActionResult")
		}
	}

	func handle(_ result: RoadEventRemoveResult) {
		self.hideRoadEvent()

		switch result {
		case let .success(actionResult):
			switch actionResult {
			case .ok:
				self.showMessage("Road event are removed!")
			case .networkError:
				self.showNetworkError()
			@unknown default:
				assertionFailure("Unknown value for ActionResult")
			}
		case let .failure(error):
			self.showCommonError(error)
		@unknown default:
			assertionFailure("Unknown value for RoadEventRemoveResult")
		}
	}

	func hideRoadEventForm() {
		self.isRoadEventFormPresented = false
	}

	func hideRoadEvent() {
		self.selectedRoadEvent = nil
	}

	private func handle(_ roadEventMapObject: RoadEventMapObject) {
		let roadEventId = roadEventMapObject.id
		let isHighlighted = self.roadEventSource.highlightedObjects.contains(roadEventId)
		self.roadEventSource.setHighlighted(directoryObjectIds: [roadEventId], highlighted: !isHighlighted)
		self.hideRoadEventForm()
		self.selectedRoadEvent = roadEventMapObject.event
	}

	private func showNetworkError() {
		self.showMessage("Network error.")
	}

	private func showCommonError(_ error: Error) {
		self.showMessage("Something went wrong: \(error)")
	}

	private func showMessage(_ message: String) {
		self.alertMessage = message
		self.isAlertShowing = true
	}
}

extension AddEventError: @retroactive CustomStringConvertible {
	public var description: String {
		switch self {
		case .networkError:
			return "Network error."
		case .noPersonalDataCollectionConsent:
			return "The user declined the collection and submission of personal data."
		case .notAuthorized:
			return "Attempt to add an anonymous event in a territory where user authorization is mandatory."
		case .territoryNotSupported:
			return "Attempt to add an event outside of MobileSDK projects."
		case .tooManyRequests:
			return "The user is creating events too frequently."
		case .unknownUserLocation:
			return "The user's current position is unknown. Traffic events can only be added with a known position."
		case .userBlocked:
			return "The user is blocked."
		case .userLocationTooFarFromEvent:
			return "The user is too far from the location of the event being added."
		@unknown default:
			assertionFailure("Unknown AddEventError type: \(self)")
			return "Unknown \(self.rawValue)"
		}
	}
}
