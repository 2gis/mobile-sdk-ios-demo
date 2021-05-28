import SwiftUI
import PlatformMapSDK

struct MapView: UIViewRepresentable {
	typealias UIViewType = UIView
	typealias Context = UIViewRepresentableContext<Self>
	private let mapUIViewFactory: () -> UIView & IMapView
	private var showsAPIVersion: Bool
	private var copyrightInsets: UIEdgeInsets
	private var copyrightAlignment: PlatformMapSDK.CopyrightAlignment

	init(
		copyrightInsets: UIEdgeInsets = .zero,
		copyrightAlignment: PlatformMapSDK.CopyrightAlignment = .bottomRight,
		showsAPIVersion: Bool = true,
		mapUIViewFactory: @escaping () -> UIView & IMapView
	) {
		self.copyrightInsets = copyrightInsets
		self.copyrightAlignment = copyrightAlignment
		self.showsAPIVersion = showsAPIVersion
		self.mapUIViewFactory = mapUIViewFactory
	}

	func makeUIView(context: Context) -> UIView {
		let mapView = self.mapUIViewFactory()
		mapView.copyrightInsets = self.copyrightInsets
		mapView.showsAPIVersion = self.showsAPIVersion
		mapView.copyrightAlignment = self.copyrightAlignment
		return mapView
	}

	func updateUIView(_ uiView: UIView, context: Context) {
		guard let mapView = uiView as? IMapView else { return }
		mapView.showsAPIVersion = self.showsAPIVersion
		mapView.copyrightInsets = self.copyrightInsets
		mapView.copyrightAlignment = self.copyrightAlignment
	}
}

extension MapView {
	func showsAPIVersion(_ show: Bool) -> MapView {
		return self.modified { $0.showsAPIVersion = show }
	}

	func copyrightInsets(_ insets: UIEdgeInsets) -> MapView {
		return self.modified { $0.copyrightInsets = insets }
	}

	func copyrightAlignment(_ alignment: PlatformMapSDK.CopyrightAlignment) -> MapView {
		return self.modified { $0.copyrightAlignment = alignment }
	}
}

private extension MapView {
	func modified(with modifier: (inout MapView) -> Void) -> MapView {
		var view = self
		modifier(&view)
		return view
	}
}
