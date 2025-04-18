import Foundation
import CoreLocation
import SwiftUI
import DGis

struct SuggestResultViewModel {
	let suggests: [SuggestViewModel]

	var isEmpty: Bool {
		self.suggests.isEmpty
	}

	init(
		result: SuggestResult? = nil,
		lastPosition: CLLocation? = nil
	) {
		let lastPositionPoint = lastPosition.map { GeoPoint(coordinate: $0.coordinate) }
		self.suggests = result?.suggests.compactMap({ ($0, lastPositionPoint) }).map(SuggestViewModel.init) ?? []
	}
}

extension SuggestResultViewModel {
	static var empty = Self()
}
