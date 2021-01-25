import SwiftUI

struct ZoomControl: UIViewRepresentable {
	typealias UIViewType = UIView
	typealias Context = UIViewRepresentableContext<Self>
	private let controlFactory: () -> UIView

	init(controlFactory: @escaping () -> UIView) {
		self.controlFactory = controlFactory
	}

	func makeUIView(context: Context) -> UIView {
		self.controlFactory()
	}

	func updateUIView(_ uiView: UIView, context: Context) {
	}
}
