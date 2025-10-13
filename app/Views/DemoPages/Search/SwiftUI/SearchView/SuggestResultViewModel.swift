import CoreLocation
import DGis
import Foundation
import SwiftUI

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
		self.suggests = result?.suggests.compactMap { ($0, lastPositionPoint) }.map(SuggestViewModel.init) ?? []
	}
}

extension SuggestResultViewModel {
	static let empty = Self()
}
