import Foundation
import UIKit

extension String {
	func width(
		constrainedHeight height: CGFloat,
		drawingOptions: NSStringDrawingOptions = .usesLineFragmentOrigin,
		font: UIFont
	) -> CGFloat {

		let constraintSize = CGSize(width: .greatestFiniteMagnitude, height: height)
		let boundingBox = self.size(
			constrainedSize: constraintSize,
			drawingOptions: drawingOptions,
			font: font
		)
		return boundingBox.width
	}

	func size(
		constrainedSize size: CGSize,
		isRounded: Bool = true,
		drawingOptions: NSStringDrawingOptions = .usesLineFragmentOrigin,
		font: UIFont
	) -> CGRect {

		let boundingBox = self.boundingRect(
			with: size,
			options: drawingOptions,
			attributes: [
				.font: font,
			],
			context: nil
		)

		return isRounded ? boundingBox.ceilBox() : boundingBox
	}
}
