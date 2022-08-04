import SwiftUI
import DGis

extension SettingsFormTextField where Value == RouteDistance {
	init(
		title: String,
		value: Binding<RouteDistance>
	) {
		self.init(
			title: title,
			value: value,
			rawToValueConverter: { RouteDistance(millimeters: (Int64($0) ?? 0) * 1000) },
			valueToRawConverter: { "\($0.millimeters / 1000)" },
			keyboardType: .numberPad
		)
	}
}
