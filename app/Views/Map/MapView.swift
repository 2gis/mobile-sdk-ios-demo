import SwiftUI
import DGis

enum MapGesturesType: CaseIterable, Identifiable {
	case `default`, custom

	var id: MapGesturesType { self }
}

struct MapView: UIViewRepresentable {
	typealias UIViewType = UIView
	typealias Context = UIViewRepresentableContext<Self>
	private let mapUIViewFactory: () -> UIView & IMapView
	private let mapGestureViewFactory: (MapGesturesType) -> (UIView & IMapGestureView)?
	private let appearance: MapAppearance?
	private var showsAPIVersion: Bool
	private var copyrightInsets: UIEdgeInsets
	private var copyrightAlignment: DGis.CopyrightAlignment
	private var mapGesturesType: MapGesturesType?

	init(
		appearance: MapAppearance?,
		copyrightInsets: UIEdgeInsets = .zero,
		copyrightAlignment: DGis.CopyrightAlignment = .bottomRight,
		showsAPIVersion: Bool = true,
		mapGesturesType: MapGesturesType? = nil,
		mapUIViewFactory: @escaping () -> UIView & IMapView,
		mapGestureViewFactory: @escaping (MapGesturesType) -> (UIView & IMapGestureView)?
	) {
		self.appearance = appearance
		self.copyrightInsets = copyrightInsets
		self.copyrightAlignment = copyrightAlignment
		self.showsAPIVersion = showsAPIVersion
		self.mapGesturesType = mapGesturesType
		self.mapUIViewFactory = mapUIViewFactory
		self.mapGestureViewFactory = mapGestureViewFactory
	}

	func makeCoordinator() -> MapViewCoordinator {
		MapViewCoordinator(mapGesturesType: self.mapGesturesType)
	}

	func makeUIView(context: Context) -> UIView {
		let mapView = self.mapUIViewFactory()
		updateGesturesView(mapView, mapGesturesType: context.coordinator.mapGesturesType)
		context.coordinator.gesturesTypeChanged = {
			[weak mapView] type in
			guard let mapView = mapView else { return }

			self.updateGesturesView(mapView, mapGesturesType: type)
		}
		self.updateMapView(mapView)
		return mapView
	}

	func updateUIView(_ uiView: UIView, context: Context) {
		guard let mapView = uiView as? IMapView else { return }
		self.updateMapView(mapView)
		context.coordinator.mapGesturesType = self.mapGesturesType
	}

	private func updateGesturesView(_ mapView: UIView & IMapView, mapGesturesType: MapGesturesType?) {
		guard let mapGesturesType = mapGesturesType else { return }
		mapView.gestureView = self.mapGestureViewFactory(mapGesturesType)
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

	func copyrightAlignment(_ alignment: DGis.CopyrightAlignment) -> MapView {
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

final class MapViewCoordinator {
	typealias GesturesTypeChangedCallback = (MapGesturesType?) -> Void
	var mapGesturesType: MapGesturesType? {
		didSet {
			if oldValue != self.mapGesturesType {
				self.gesturesTypeChanged?(self.mapGesturesType)
			}
		}
	}
	var gesturesTypeChanged: GesturesTypeChangedCallback?

	init(mapGesturesType: MapGesturesType?) {
		self.mapGesturesType = mapGesturesType
	}
}
