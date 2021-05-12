import SwiftUI
import Combine
import PlatformSDK

final class VisibleAreaDetectionDemoViewModel: ObservableObject {
	private enum Constants {
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
	var isTrackingActive: Bool {
		return self.trackingState != .inactive
	}
	var visibleAreaIndicatorState: VisibleAreaState? {
		guard case let .active(state) = self.trackingState else { return nil }
		return state
	}
	private let map: Map
	private var initialRect: GeoRect?
	private var initialRectCancellable: PlatformSDK.Cancellable?

	init(map: Map) {
		self.map = map
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
		self.initialRect = rect.expanded(by: Constants.initialRectExpansionRatio)
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
