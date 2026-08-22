import SwiftUI

struct LazyView<Content: View>: View {
	private let build: () -> Content

	init(_ viewBuilder: @autoclosure @escaping () -> Content) {
		self.build = viewBuilder
	}

	var body: Content {
		self.build()
	}
}
