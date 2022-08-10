import UIKit

extension UIColor {
	convenience init?(hex hexString: String?) {
		guard let hexString = hexString else { return nil }

		let scanner = Scanner(string: hexString)
		scanner.scanLocation = 1

		var hex = UInt32()
		guard scanner.scanHexInt32(&hex) else { return nil }
		self.init(rgb: hex)
	}

	convenience init(rgb: UInt32) {
		let red = CGFloat((rgb >> 16) & 0xff) / 255
		let green = CGFloat((rgb >> 8) & 0xff) / 255
		let blue = CGFloat((rgb >> 0) & 0xff) / 255
		self.init(red: red, green: green, blue: blue, alpha: 1)
	}
}
