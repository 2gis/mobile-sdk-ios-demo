import SwiftUI
import DGis

struct PaddingRect {
	var top: CGFloat = 0
	var bottom: CGFloat = 0
	var left: CGFloat = 0
	var right: CGFloat = 0
}

extension PaddingRect {
	func toDGisPadding() -> Padding {
		return Padding(
			left: UInt32(self.left),
			top: UInt32(self.top),
			right: UInt32(self.right),
			bottom: UInt32(self.bottom)
		)
	}
}
