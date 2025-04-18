import UIKit
import DGis

class RoadEventsDemoUIViewController: UIViewController, RoadEventsDemoUIViewModel, RoadEventsFilterViewControllerDelegate {
	private let viewModel: RoadEventsDemoViewModel
	private let mapFactory: IMapFactory
	private let mapControlFactory: IMapControlFactory
	private let mapOverlayFactory: RoadEventsMapOverlayFactory
	private let mapOverlay: IMapOverlayView
	private let zoomControl: ZoomControl
	private let currentLocationControl: CurrentLocationControl
	private let createRoadEventControl: CreateRoadEventControl

	init(
		viewModel: RoadEventsDemoViewModel,
		mapFactory: IMapFactory,
		mapOverlayFactory: RoadEventsMapOverlayFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.mapControlFactory = self.mapFactory.mapControlFactory
		self.mapOverlayFactory = mapOverlayFactory

		self.mapOverlay = self.mapOverlayFactory.makeOverlayView()
		self.zoomControl = self.mapControlFactory.makeZoomControl()
		self.currentLocationControl = self.mapControlFactory.makeCurrentLocationControl()
		self.createRoadEventControl = self.mapControlFactory.makeCreateRoadEventControl()

		super.init(nibName: nil, bundle: nil)
		self.viewModel.delegate = self
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()

		navigationItem.rightBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
			style: .plain,
			target: self,
			action: #selector(self.showFilterView)
		)
	}

	private func setupUI() {
		// Map
		let mapView = mapFactory.mapView
		mapView.addObjectTappedCallback(callback: .init(
			callback: { [viewModel = self.viewModel] objectInfo in
				viewModel.tap(objectInfo: objectInfo)
			}
		))
		mapView.showsAPIVersion = true
		mapView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(mapView)

		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: view.topAnchor),
			mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])

		// RoadEventsOverlay
		self.view.addSubview(self.mapOverlay)
		self.mapOverlay.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.mapOverlay.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.mapOverlay.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.mapOverlay.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.mapOverlay.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
		])

		// Map controls
		self.createRoadEventControl.addTarget(self, action: #selector(self.createRoadEvent), for: .touchUpInside)

		[self.zoomControl, self.currentLocationControl, self.createRoadEventControl].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
		}

		NSLayoutConstraint.activate([
			self.zoomControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			self.zoomControl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			self.zoomControl.widthAnchor.constraint(equalToConstant: 48),
			self.zoomControl.heightAnchor.constraint(equalToConstant: 102),

			self.currentLocationControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			self.currentLocationControl.bottomAnchor.constraint(equalTo: self.createRoadEventControl.topAnchor, constant: -10),
			self.currentLocationControl.widthAnchor.constraint(equalToConstant: 48),
			self.currentLocationControl.heightAnchor.constraint(equalToConstant: 48),

			self.createRoadEventControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			self.createRoadEventControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -170),
			self.createRoadEventControl.widthAnchor.constraint(equalToConstant: 48),
			self.createRoadEventControl.heightAnchor.constraint(equalToConstant: 48)
		])
	}

	func didUpdateRoadEventFormVisibility(_ isVisible: Bool) {
		self.navigationController?.setNavigationBarHidden(isVisible, animated: true)
		let controls = [self.zoomControl, self.currentLocationControl, self.createRoadEventControl]
		controls.forEach { $0.isHidden = isVisible }
	}

	func didShowAlert(message: String) {
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default))
		present(alert, animated: true)
	}

	func didUpdateFiltersVisibility(_ isVisible: Bool) {
		self.viewModel.isFiltersVisible = isVisible
	}

	func didUpdateVisibleEvents(_ visibleEvents: DGis.RoadEventDisplayCategoryOptionSet) {
		self.viewModel.visibleEvents = visibleEvents
	}

	@objc private func createRoadEvent() {
		self.viewModel.createRoadEvent()
	}

	@objc private func showFilterView() {
		let filterVC = RoadEventsFilterViewController(visibleEvents: self.viewModel.visibleEvents)
		filterVC.delegate = self
		let navController = UINavigationController(rootViewController: filterVC)
		present(navController, animated: true)
	}
}
