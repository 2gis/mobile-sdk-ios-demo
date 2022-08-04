import SwiftUI
import DGis

struct NavigatorView: UIViewRepresentable {
	typealias UIViewType = UIView
	typealias Context = UIViewRepresentableContext<Self>

	private let mapFactory: IMapFactory
	private let navigationViewFactory: INavigationViewFactory
	private let navigationManager: NavigationManager
	private let roadEventCardPresenter: IRoadEventCardPresenter
	private let onCloseButtonTapped: (() -> Void)?
	private let onMapTapped: ((CGPoint) -> Void)?
	private let onMapLongPressed: ((CGPoint) -> Void)?

	init(
		mapFactory: IMapFactory,
		navigationViewFactory: INavigationViewFactory,
		navigationManager: NavigationManager,
		roadEventCardPresenter: IRoadEventCardPresenter,
		onCloseButtonTapped: (() -> Void)?,
		onMapTapped: ((CGPoint) -> Void)?,
		onMapLongPressed: ((CGPoint) -> Void)?
	) {
		self.mapFactory = mapFactory
		self.navigationViewFactory = navigationViewFactory
		self.navigationManager = navigationManager
		self.roadEventCardPresenter = roadEventCardPresenter
		self.onCloseButtonTapped = onCloseButtonTapped
		self.onMapTapped = onMapTapped
		self.onMapLongPressed = onMapLongPressed
	}

	func makeUIView(context: Context) -> UIView {
		let navigatorMapView = NavigatorMapView(
			mapFactory: self.mapFactory,
			navigationViewFactory: self.navigationViewFactory,
			navigationManager: self.navigationManager
		)
		self.roadEventCardPresenter.delegate = navigatorMapView
		navigatorMapView.onCloseButtonTapped = self.onCloseButtonTapped
		navigatorMapView.onMapTapped = self.onMapTapped
		navigatorMapView.onMapLongPressed = self.onMapLongPressed
		return navigatorMapView
	}
	
	func updateUIView(_ uiView: UIView, context: Context) {}
}

private class NavigatorMapView: UIView {
	var onCloseButtonTapped: (() -> Void)?
	var onMapTapped: ((CGPoint) -> Void)?
	var onMapLongPressed: ((CGPoint) -> Void)?

	private lazy var mapView: UIView & IMapView = self.mapFactory.mapView
	private lazy var navigationView: UIView & INavigationView =
		self.navigationViewFactory.makeNavigationView(
			map: self.mapFactory.map,
			navigationManager: self.navigationManager
		)

	private let mapFactory: IMapFactory
	private let navigationViewFactory: INavigationViewFactory
	private let navigationManager: NavigationManager

	init(
		mapFactory: IMapFactory,
		navigationViewFactory: INavigationViewFactory,
		navigationManager: NavigationManager
	) {
		self.mapFactory = mapFactory
		self.navigationViewFactory = navigationViewFactory
		self.navigationManager = navigationManager
		super.init(frame: .zero)
		self.setup()
	}

	required init?(coder: NSCoder) {
		fatalError("init(mapFactory:navigationViewFactory:navigationManager:)")
	}

	func showRoadEvent(_ event: RoadEvent) {
		self.navigationView.showRoadEvent(event)
	}

	private func setup() {
		self.mapView.translatesAutoresizingMaskIntoConstraints = false

		let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.mapViewTapped(_:)))
		tapRecognizer.cancelsTouchesInView = false
		self.mapView.addGestureRecognizer(tapRecognizer)

		let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.mapViewLongPressed(_:)))
		longPressRecognizer.cancelsTouchesInView = false
		self.mapView.addGestureRecognizer(longPressRecognizer)

		self.addSubview(mapView)

		self.navigationView.visibleAreaEdgeInsetsChangedCallback = {
			[weak self] insets in
			guard let mapView = self?.mapView else { return }

			mapView.copyrightInsets.bottom = insets.bottom - mapView.safeAreaInsets.bottom
		}
		self.navigationView.finishButtonCallback = {
			[weak self] in
			self?.onCloseButtonTapped?()
		}
		self.navigationView.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.navigationView)
		NSLayoutConstraint.activate([
			self.mapView.leftAnchor.constraint(equalTo: self.leftAnchor),
			self.mapView.rightAnchor.constraint(equalTo: self.rightAnchor),
			self.mapView.topAnchor.constraint(equalTo: self.topAnchor),
			self.mapView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.navigationView.leftAnchor.constraint(equalTo: self.leftAnchor),
			self.navigationView.rightAnchor.constraint(equalTo: self.rightAnchor),
			self.navigationView.topAnchor.constraint(equalTo: self.topAnchor),
			self.navigationView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
		])
	}

	@objc private func mapViewTapped(_ recognizer: UITapGestureRecognizer) {
		self.onMapTapped?(recognizer.location(in: self))
	}

	@objc private func mapViewLongPressed(_ recognizer: UILongPressGestureRecognizer) {
		self.onMapLongPressed?(recognizer.location(in: self))
	}
}

extension NavigatorMapView: RoadEventCardPresenterDelegate {
	func roadEventCardPresenter(
		_ presenter: IRoadEventCardPresenter,
		didRequestToPresent roadEvent: RoadEvent,
		outputCallback: ((RoadEventCardPresenterOutput) -> Void)?
	) {
		self.navigationView.showRoadEvent(roadEvent)
	}
}
