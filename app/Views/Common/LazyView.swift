import SwiftUI

struct LazyView<Content: View>: View {
	private let viewBuilder: () -> Content

	init(_ viewBuilder: @autoclosure @escaping () -> Content) {
		self.viewBuilder = viewBuilder
	}

	var body: Content {
		self.viewBuilder()
	}
}
