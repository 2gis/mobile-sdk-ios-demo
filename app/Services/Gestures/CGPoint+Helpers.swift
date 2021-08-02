import UIKit

extension CGPoint {
	func isNear(_ point: CGPoint, maxDistance: CGFloat) -> Bool {
		return self.distance(point) < maxDistance
	}

	func distance(_ point: CGPoint) -> CGFloat {
		let dx = self.x - point.x
		let dy = self.y - point.y
		return hypot(dx, dy)
	}
}
