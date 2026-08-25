import UIKit

class FeedbackGenerator {
	@MainActor
	func impactFeedback(_ style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) {
		let generator = UIImpactFeedbackGenerator(style: style)
		generator.impactOccurred()
	}
}
