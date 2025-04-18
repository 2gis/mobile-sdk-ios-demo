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
		let red = CGFloat((rgb >> 16) & 0xff) / 255
		let green = CGFloat((rgb >> 8) & 0xff) / 255
		let blue = CGFloat((rgb >> 0) & 0xff) / 255
		self.init(red: red, green: green, blue: blue, alpha: 1)
	}
}
