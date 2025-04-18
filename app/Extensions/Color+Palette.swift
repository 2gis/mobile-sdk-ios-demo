import SwiftUI

extension Color {
	static let primaryTitle: Color = Color("colors/primary_title")
	static let closeMenuActionButtons = Color(hex: 0x006B44)
}

extension Color {
	init(hex: UInt, alpha: Double = 1) {
		self.init(
			.sRGB,
			red: Double((hex >> 16) & 0xff) / 255,
			green: Double((hex >> 08) & 0xff) / 255,
			blue: Double((hex >> 00) & 0xff) / 255,
			opacity: alpha
		)
	}
}
