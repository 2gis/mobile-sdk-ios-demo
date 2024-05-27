import SwiftUI

extension Formatter {
	static let tiltFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.allowsFloats = true
		formatter.decimalSeparator = "."
		formatter.minimum = 0
		formatter.maximum = 60
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 2
		return formatter
	}()
	
	static let zoomFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.allowsFloats = true
		formatter.decimalSeparator = "."
		formatter.minimum = 0
		formatter.maximum = 20
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 2
		return formatter
	}()
	
	static let bearingFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		formatter.allowsFloats = true
		formatter.decimalSeparator = "."
		formatter.minimum = 0
		formatter.maximum = 360
		formatter.minimumFractionDigits = 0
		formatter.maximumFractionDigits = 2
		return formatter
	}()
}
