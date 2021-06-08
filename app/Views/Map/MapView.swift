import SwiftUI
import PlatformSDK

struct MapView: UIViewRepresentable {
	typealias UIViewType = UIView
	typealias Context = UIViewRepresentableContext<Self>
	private let mapUIViewFactory: () -> UIView & IMapView
	private let appearance: MapAppearance?
	private var showsAPIVersion: Bool
	private var copyrightInsets: UIEdgeInsets
	private var copyrightAlignment: PlatformSDK.CopyrightAlignment

	init(
		appearance: MapAppearance?,
		copyrightInsets: UIEdgeInsets = .zero,
		copyrightAlignment: PlatformSDK.CopyrightAlignment = .bottomRight,
		showsAPIVersion: Bool = true,
		mapUIViewFactory: @escaping () -> UIView & IMapView
	) {
		self.appearance = appearance
		self.copyrightInsets = copyrightInsets
		self.copyrightAlignment = copyrightAlignment
		self.showsAPIVersion = showsAPIVersion
		self.mapUIViewFactory = mapUIViewFactory
	}

	func makeUIView(context: Context) -> UIView {
		let mapView = self.mapUIViewFactory()
		self.updateMapView(mapView)
		return mapView
	}

	func updateUIView(_ uiView: UIView, context: Context) {
		guard let mapView = uiView as? IMapView else { return }
		self.updateMapView(mapView)
	}

	private func updateMapView(_ mapView: UIView & IMapView) {
		if let appearance = self.appearance, appearance != mapView.appearance {
			mapView.appearance = appearance
		}
		mapView.copyrightInsets = self.copyrightInsets
		mapView.showsAPIVersion = self.showsAPIVersion
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

	func copyrightAlignment(_ alignment: PlatformSDK.CopyrightAlignment) -> MapView {
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
