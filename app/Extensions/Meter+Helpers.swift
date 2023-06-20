import SwiftUI
import DGis

extension Meter: CustomStringConvertible {
	private enum Constants {
		static let metersInKm: Float = 1000.0
	}

	public var description: String {
		self.valueToString()
	}

	public var descriptionSuggest: String {
		String(" · \(self.valueToString())")
	}

	private func valueToString() -> String {
		self.value >= Constants.metersInKm ? String(format: "%.1f km", self.value / Constants.metersInKm) : String(format: "%.1f m", self.value)
	}
}
