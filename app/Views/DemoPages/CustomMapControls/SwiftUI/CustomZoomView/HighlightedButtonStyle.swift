import SwiftUI

struct HighlightedButtonStyle: ButtonStyle {
	private let highlighted: Binding<Bool>
	private let applyOverlay: Bool

	init(highlighted: Binding<Bool>, applyOverlay: Bool = false) {
		self.highlighted = highlighted
		self.applyOverlay = applyOverlay
	}

	func makeBody(configuration: Configuration) -> some View {
		DispatchQueue.main.async { [self] in
			self.highlighted.wrappedValue = configuration.isPressed
		}
		if self.applyOverlay, configuration.isPressed {
			return AnyView(configuration.label
				.overlay(
					Rectangle()
						.fill(Color("colors/button_highlight"))
						.allowsHitTesting(false)
				)
			)
		} else {
			return AnyView(configuration.label)
		}
	}
}
