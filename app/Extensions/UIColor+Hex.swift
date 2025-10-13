import UIKit

extension UIColor {
	convenience init?(hex hexString: String?) {
		guard let hexString = hexString?.trimmingCharacters(in: CharacterSet.alphanumerics.inverted) else { return nil }

		let scanner = Scanner(string: hexString)
		var hex = UInt64()

		guard scanner.scanHexInt64(&hex) else { return nil }
		self.init(rgb: hex)
	}

	convenience init(rgb: UInt64) {
		let red = CGFloat((rgb >> 16) & 0xFF) / 255
		let green = CGFloat((rgb >> 8) & 0xFF) / 255
		let blue = CGFloat((rgb >> 0) & 0xFF) / 255
		self.init(red: red, green: green, blue: blue, alpha: 1)
	}

	convenience init(hex: String) {
		var cString: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
		var rgbValue: UInt64 = 0x999999FF

		if cString.hasPrefix("#") {
			cString.remove(at: cString.startIndex)
		}

		if cString.count == 3 {
			cString = cString.map { "\($0)\($0)" }.joined()
			cString.append("FF")
		} else if cString.count == 4 {
			cString = cString.map { "\($0)\($0)" }.joined()
		} else if cString.count == 6 {
			cString.append("FF")
		}

		if cString.count == 8 {
			Scanner(string: cString).scanHexInt64(&rgbValue)
		}

		self.init(
			red: CGFloat((rgbValue & 0xFF000000) >> 24) / 255.0,
			green: CGFloat((rgbValue & 0x00FF0000) >> 16) / 255.0,
			blue: CGFloat((rgbValue & 0x0000FF00) >> 8) / 255.0,
			alpha: CGFloat(rgbValue & 0x000000FF) / 255.0
		)
	}
}
