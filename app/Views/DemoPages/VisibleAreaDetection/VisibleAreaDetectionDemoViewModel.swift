import SwiftUI
import Combine
import DGis

final class VisibleAreaDetectionDemoViewModel: ObservableObject {
	private enum Constants {
		static let minRectExpansionRatio = 1.0
		static let initialRectExpansionRatio = 1.5
	}

	enum VisibleAreaState {
		case inside
		case outside
	}

	enum VisibleAreaTrackingState {
		case inactive
		case active(VisibleAreaState)
	}

	@Published var trackingState: VisibleAreaTrackingState = .inactive
	@Published var rectExpansionRatio: Double
	@Published var isErrorAlertShown: Bool = false
	var isTrackingActive: Bool {
		return self.trackingState != .inactive
	}
	var visibleAreaIndicatorState: VisibleAreaState? {
		guard case let .active(state) = self.trackingState else { return nil }
		return state
	}
	var minRectExpansionRatio: Double {
		Constants.minRectExpansionRatio
	}
	var maxRectExpansionRatio: Double {
		Constants.initialRectExpansionRatio
	}
	private let map: Map
	private let mapObjectManager: MapObjectManager
	private let mapSourceFactory: IMapSourceFactory
	private var initialRect: GeoRect? {
		didSet {
			self.updateVisibleAreaPolygon()
		}
	}
	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}
	private var initialRectCancellable: DGis.Cancellable?

	init(
		map: Map,
		mapObjectManager: MapObjectManager,
		mapSourceFactory: IMapSourceFactory
	) {
		self.map = map
		self.mapObjectManager = mapObjectManager
		self.mapSourceFactory = mapSourceFactory
		self.rectExpansionRatio = Constants.initialRectExpansionRatio

		let source = mapSourceFactory.makeMyLocationMapObjectSource()
		map.addSource(source: source)
	}

	func detectExtendedVisibleRectChange() {
		let visibleRectChannel = self.map.camera.visibleRectChannel
		self.formInitialVisibleRect(from: visibleRectChannel.value)
		self.initialRectCancellable = visibleRectChannel.sinkOnMainThread{ [weak self] rect in
			self?.updateVisibleRect(rect)
		}
	}

	func stopVisibleRectTracking() {
		self.initialRect = nil
		self.initialRectCancellable?.cancel()
		self.initialRectCancellable = nil
		self.trackingState = .inactive
	}

	private func formInitialVisibleRect(from rect: GeoRect) {
		let expandedRect = rect.expanded(by: self.rectExpansionRatio)
		if expandedRect.isValid {
			self.initialRect = expandedRect
		} else {
			self.initialRect = rect
		}
	}

	private func updateVisibleRect(_ rect: GeoRect) {
		if let initialRect = self.initialRect,
			initialRect.contains(rect) {
			// Current visible rect is within the initial expanded rect.
			self.trackingState = .active(.inside)
		} else {
			// Current visible rect is outside the initial expanded rect.
			self.trackingState = .active(.outside)
		}
	}

	private func updateVisibleAreaPolygon() {
		if let rect = self.initialRect {
			let southEastPoint = GeoPoint(latitude: rect.southWestPoint.latitude, longitude: rect.northEastPoint.longitude)
			let northWestPoint = GeoPoint(latitude: rect.northEastPoint.latitude, longitude: rect.southWestPoint.longitude)
			let options = PolygonOptions(
				contours: [[
					rect.northEastPoint,
					southEastPoint,
					rect.southWestPoint,
					northWestPoint
				]],
				color: Color(red: 0, green: 1, blue: 0, alpha: 0.3)
			)
			let polygon: Polygon
			do {
				polygon = try Polygon(options: options)
			} catch let error as SimpleError {
				self.errorMessage = error.description
				return
			} catch {
				self.errorMessage = error.localizedDescription
				return
			}
			self.mapObjectManager.addObject(item: polygon)
		} else {
			self.mapObjectManager.removeAll()
		}
	}
}

extension VisibleAreaDetectionDemoViewModel.VisibleAreaTrackingState: Equatable {

	static func == (lhs: Self, rhs: Self) -> Bool {
		switch (lhs, rhs) {
			case (.inactive, .inactive):
				return true
			case (.active(let lhs), .active(let rhs)):
				return lhs == rhs
			default:
				return false
		}
	}
}
