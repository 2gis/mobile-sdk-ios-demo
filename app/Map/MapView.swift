import SwiftUI
import PlatformSDK

struct MapView: UIViewRepresentable {
	typealias UIViewType = UIView
	typealias Context = UIViewRepresentableContext<Self>
	private let mapUIViewFactory: () -> UIView

	init(mapUIViewFactory: @escaping () -> UIView) {
		self.mapUIViewFactory = mapUIViewFactory
	}

	func makeUIView(context: Context) -> UIView {
		self.mapUIViewFactory()
	}

	func updateUIView(_ uiView: UIView, context: Context) {
	}
}
