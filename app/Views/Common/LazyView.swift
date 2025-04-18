import SwiftUI

struct LazyView<Content: View>: View {

	private let contentBuilder: LazyViewContentBuilder<Content>

	init(_ viewBuilder: @autoclosure @escaping () -> Content) {
		self.contentBuilder = LazyViewContentBuilder(viewBuilder)
	}

	var body: Content {
		self.contentBuilder.build()
	}
}

private final class LazyViewContentBuilder<Content: View> {
	private let viewBuilder: () -> Content
	private lazy var content: Content = {
		self.viewBuilder()
	}()

	init(_ viewBuilder: @escaping () -> Content) {
		self.viewBuilder = viewBuilder
	}

	func build() -> Content {
		self.content
	}
}
