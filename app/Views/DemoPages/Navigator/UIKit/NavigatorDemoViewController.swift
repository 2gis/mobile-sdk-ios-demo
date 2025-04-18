import DGis
import UIKit

class NavigatorDemoViewController: UIViewController {
	private let mapFactory: IMapFactory
	private let mapControlFactory: IMapControlFactory
	private var mapView: UIView & IMapView
	private var viewModel: NavigatorDemoViewModel

	private var navigationView: (UIView & INavigationView)!
	private var trafficControl: TrafficControl!
	private var zoomControl: ZoomControl!
	private var compassControl: CompassControl!
	private var currentLocationControl: CurrentLocationControl!
	private var indoorControl: IndoorControl!
	private var goButton: UIButton!
	private var crosshair: UIImageView!
	private var settingsView: UIView!
	private var settingsViewPortraitConstraints: [NSLayoutConstraint] = []
	private var settingsViewLandscapeConstraints: [NSLayoutConstraint] = []

	init(
		mapFactory: IMapFactory,
		viewModel: NavigatorDemoViewModel,
		navigationFactory: @escaping (NavigationViewOptions) throws -> INavigationViewFactory
	) {
		self.mapFactory = mapFactory
		self.mapControlFactory = mapFactory.mapControlFactory
		self.mapView = mapFactory.mapView
		self.viewModel = viewModel

		super.init(nibName: nil, bundle: nil)

		self.navigationView = self.makeNavigationView(factory: navigationFactory)
		self.trafficControl = self.mapControlFactory.makeTrafficControl()
		self.zoomControl = self.mapControlFactory.makeZoomControl()
		self.compassControl = self.mapControlFactory.makeCompassControl()
		self.currentLocationControl = self.mapControlFactory.makeCurrentLocationControl()
		self.indoorControl = self.mapControlFactory.makeIndoorControl()
		self.goButton = self.makeGoButton()
		self.crosshair = self.makeCrosshair()
		self.settingsView = NavigatorSettingsUIView(
			viewModel: self.viewModel.navigatorSettingsViewModel,
			onGoTapped: { [weak self] in
				self?.settingsView.isHidden = true
				self?.viewModel.startNavigation()
			},
			onCancelTapped: { [weak self] in
				self?.hideMapUIElements(false)
				self?.settingsView.isHidden = true
			}
		)
		self.viewModel.stateChangedCallback = { [weak self] in
			guard let self else { return }
			self.handleStateChange()
		}
		self.viewModel.requestChangedCallback = { [weak self] in
			guard let self else { return }
			self.handleRequestChange()
		}
		self.viewModel.roadEventCardPresenterCallback = { [weak self] roadEvent in
			guard let self else { return }
			self.navigationView.showRoadEvent(roadEvent)
		}
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
		self.mapView.showsAPIVersion = true
		self.mapView.addObjectTappedCallback(callback: .init(callback: { [viewModel = self.viewModel] objectInfo in
			viewModel.tap(objectInfo)
		}))
		self.mapView.addObjectLongPressCallback(callback: .init(callback: { [viewModel = self.viewModel] objectInfo in
			viewModel.longPress(objectInfo)
		}))
		self.navigationView.finishButtonCallback = { [viewModel = self.viewModel] in
			viewModel.stopNavigation()
		}
	}

	private func makeNavigationView(
		factory: @escaping (NavigationViewOptions) throws -> INavigationViewFactory
	) -> UIView & INavigationView {
		var options = NavigationViewOptions.default
		if self.viewModel.settingsService.navigatorDashboardButton == .exitButton {
			var settings = DashboardButtonSettings.default
			settings.icon = UIImage(named: "svg/exit_button_dashboard")
			settings.callback = { [weak self] in self?.presentCloseMenuAlert() }
			options.dashboardButtonSettings = settings
		}
		if self.viewModel.settingsService.navigatorTheme == .custom {
			options.theme = NavigationViewTheme.custom
		}
		let navigationFactory = try! factory(options)
		switch self.viewModel.settingsService.navigatorControls {
			case .default:
			let navigationView = navigationFactory.makeNavigationView(
				map: self.mapFactory.map,
				navigationManager: self.viewModel.navigationManager
			)
			return navigationView
			case .customControls:
			let navigationViewControlsFactory = navigationFactory.makeNavigationViewControlsFactory()
			let navigationView = navigationFactory.makeNavigationView(
				map: self.mapFactory.map,
				navigationManager: self.viewModel.navigationManager,
				navigationViewControlsFactory: CustomNavigationViewControlsFactory(navigationViewControlsFactory: navigationViewControlsFactory),
				navigationMapControlsFactory: CustomNavigationMapControlsFactory(mapFactory: self.mapFactory, navigationViewFactory: navigationFactory))
			return navigationView
		}
	}

	private func setupUI() {
		self.view.backgroundColor = .systemBackground
		self.mapView.translatesAutoresizingMaskIntoConstraints = false
		self.navigationView.translatesAutoresizingMaskIntoConstraints = false
		self.settingsView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(self.mapView)
		self.view.addSubview(self.navigationView)
		self.mapView.addSubview(self.settingsView)
		self.settingsView.isHidden = true

		NSLayoutConstraint.activate([
			self.mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
		])

		NSLayoutConstraint.activate([
			self.navigationView.topAnchor.constraint(equalTo: self.mapView.topAnchor),
			self.navigationView.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor),
			self.navigationView.leadingAnchor.constraint(equalTo: self.mapView.leadingAnchor),
			self.navigationView.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor),
		])

		self.settingsViewPortraitConstraints = [
			self.settingsView.leadingAnchor.constraint(equalTo: self.mapView.leadingAnchor, constant: 40),
			self.settingsView.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor, constant: -40),
			self.settingsView.topAnchor.constraint(equalTo: self.mapView.topAnchor, constant: 200),
			self.settingsView.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor, constant: -200),
		]

		self.settingsViewLandscapeConstraints = [
			self.settingsView.leadingAnchor.constraint(equalTo: self.mapView.leadingAnchor, constant: 200),
			self.settingsView.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor, constant: -200),
			self.settingsView.topAnchor.constraint(equalTo: self.mapView.topAnchor, constant: 40),
			self.settingsView.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor, constant: -40),
		]
		self.updateSettingsConstraints(for: self.view.bounds.size)

		// Add map UI elements
		for item in [self.indoorControl, self.trafficControl, self.zoomControl, self.compassControl, self.currentLocationControl, self.crosshair, self.goButton] {
			guard let item else { continue }
			item.translatesAutoresizingMaskIntoConstraints = false
			self.mapView.addSubview(item)
		}
		self.setMapUIElementsConstraints()
	}

	private func setMapUIElementsConstraints() {
		NSLayoutConstraint.activate([
			self.indoorControl.leadingAnchor.constraint(equalTo: self.mapView.leadingAnchor, constant: 10),
			self.indoorControl.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor),
			self.indoorControl.widthAnchor.constraint(equalToConstant: 38),
			self.indoorControl.heightAnchor.constraint(equalToConstant: 119),
		])

		NSLayoutConstraint.activate([
			self.trafficControl.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor, constant: -10),
			self.trafficControl.topAnchor.constraint(equalTo: self.mapView.safeAreaLayoutGuide.topAnchor, constant: 20),
			self.trafficControl.widthAnchor.constraint(equalToConstant: 48),
		])

		NSLayoutConstraint.activate([
			self.zoomControl.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor, constant: -10),
			self.zoomControl.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor),
			self.zoomControl.widthAnchor.constraint(equalToConstant: 48),
			self.zoomControl.heightAnchor.constraint(equalToConstant: 102),
		])

		NSLayoutConstraint.activate([
			self.compassControl.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor, constant: -10),
			self.compassControl.bottomAnchor.constraint(equalTo: self.currentLocationControl.topAnchor, constant: -10),
			self.compassControl.widthAnchor.constraint(equalToConstant: 48),
		])

		NSLayoutConstraint.activate([
			self.currentLocationControl.trailingAnchor.constraint(equalTo: self.mapView.trailingAnchor, constant: -10),
			self.currentLocationControl.bottomAnchor.constraint(equalTo: self.mapView.safeAreaLayoutGuide.bottomAnchor, constant: -10),
			self.currentLocationControl.widthAnchor.constraint(equalToConstant: 48),
		])

		NSLayoutConstraint.activate([
			self.crosshair.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor),
			self.crosshair.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor),
		])

		NSLayoutConstraint.activate([
			self.goButton.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor),
			self.goButton.bottomAnchor.constraint(equalTo: self.crosshair.topAnchor, constant: -10),
		])
	}

	private func updateSettingsConstraints(for size: CGSize) {
		let isPortrait = size.height > size.width
		NSLayoutConstraint.deactivate(self.settingsViewPortraitConstraints + self.settingsViewLandscapeConstraints)
		NSLayoutConstraint.activate(isPortrait ? self.settingsViewPortraitConstraints : self.settingsViewLandscapeConstraints)
	}

	private func handleStateChange() {
		switch self.viewModel.state {
		case .targetPointSearch:
			self.hideMapUIElements(false)
		default:
			self.hideMapUIElements(true)
		}
	}

	private func handleRequestChange() {
		switch self.viewModel.request {
		case let .routeSelection(routes):
			self.presentRouteSelectionAlert(routes: routes, from: self)
		case let .addIntermediatePoint(point):
			self.presentAddIntermediatePointAlert(routePoint: point, from: self)
		default:
			break
		}
	}

	private func presentRouteSelectionAlert(routes: [TrafficRoute], from controller: UIViewController) {
		let alertController = UIAlertController(title: "Which route will we take?", message: nil, preferredStyle: .actionSheet)
		for route in routes {
			let action = UIAlertAction(title: route.description, style: .default) { _ in
				self.viewModel.select(route: route)
			}
			alertController.addAction(action)
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
			self.self.viewModel.stopNavigation()
		}
		alertController.addAction(cancelAction)

		// iPad support
		if let popover = alertController.popoverPresentationController {
			popover.sourceView = controller.view
			popover.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
			popover.permittedArrowDirections = []
		}
		DispatchQueue.main.async {
			controller.present(alertController, animated: true, completion: nil)
		}
	}

	private func presentAddIntermediatePointAlert(routePoint: RouteSearchPoint, from controller: UIViewController) {
		let title = self.viewModel.isFreeRoam ? "Add a destination point?" : "Add an intermediate point?"
		let alertController = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)

		let submitAction = UIAlertAction(title: "Submit", style: .default) { _ in
			self.viewModel.addIntermediatePoint(routePoint: routePoint)
		}
		alertController.addAction(submitAction)

		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
			self.viewModel.cancelAddIntermediatePoint()
		}
		alertController.addAction(cancelAction)

		// iPad support
		if let popover = alertController.popoverPresentationController {
			popover.sourceView = controller.view
			popover.sourceRect = CGRect(x: controller.view.bounds.midX, y: controller.view.bounds.midY, width: 0, height: 0)
			popover.permittedArrowDirections = []
		}
		DispatchQueue.main.async {
			controller.present(alertController, animated: true, completion: nil)
		}
	}

	private func hideMapUIElements(_ hide: Bool) {
		DispatchQueue.main.async {
			let elements: [UIView] = [
				self.indoorControl,
				self.trafficControl,
				self.zoomControl,
				self.compassControl,
				self.currentLocationControl,
				self.crosshair,
				self.goButton
			]
			if hide {
				elements.forEach { $0.removeFromSuperview() }
			} else {
				elements.forEach { self.mapView.addSubview($0) }
				self.setMapUIElementsConstraints()
			}
			self.navigationController?.setNavigationBarHidden(hide, animated: true)
		}
	}

	private func makeCrosshair() -> UIImageView {
		let crosshair = UIImageView()
		crosshair.translatesAutoresizingMaskIntoConstraints = false
		crosshair.image = UIImage(systemName: "xmark", withConfiguration: UIImage.SymbolConfiguration(weight: .bold))
		crosshair.tintColor = .red
		return crosshair
	}

	private func makeGoButton() -> UIButton {
		let goButton = UIButton(type: .system)
		goButton.setTitle("Go here?", for: .normal)
		goButton.translatesAutoresizingMaskIntoConstraints = false
		goButton.backgroundColor = .systemBackground
		goButton.layer.cornerRadius = 12
		goButton.layer.shadowColor = UIColor.black.cgColor
		goButton.layer.shadowOpacity = 0.3
		goButton.layer.shadowOffset = CGSize(width: 0, height: 2)
		goButton.layer.shadowRadius = 2
		goButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
		goButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
		goButton.addTarget(self, action: #selector(self.goButtonTapped), for: .touchUpInside)
		return goButton
	}

	private func presentCloseMenuAlert() {
		let alert = UIAlertController(title: "Back to Home page?", message: nil, preferredStyle: .alert)
		let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] _ in
			self?.viewModel.navigationManager.stop()
			self?.navigationController?.popViewController(animated: true)
		}
		let noAction = UIAlertAction(title: "No", style: .cancel)
		alert.addAction(yesAction)
		alert.addAction(noAction)
		self.present(alert, animated: true, completion: nil)
	}

	@objc private func goButtonTapped() {
		self.hideMapUIElements(true)
		self.settingsView.isHidden = false
	}

	override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
		super.viewWillTransition(to: size, with: coordinator)
		coordinator.animate(alongsideTransition: { _ in
			self.updateSettingsConstraints(for: size)
		})
	}
}
