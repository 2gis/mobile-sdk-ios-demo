import DGis
import UIKit

class CustomMapControlsDemoViewController: UIViewController {
	private let viewModel: CustomMapControlsDemoViewModel
	private let mapFactory: IMapFactory
	private let segmentedControl: UISegmentedControl
	private let zoomControlContainer: UIView

	init(viewModel: CustomMapControlsDemoViewModel, mapFactory: IMapFactory) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory

		self.segmentedControl = UISegmentedControl(items: viewModel.controlTypes.map(\.title))
		self.zoomControlContainer = UIView()

		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupMapView()
		self.setupControls()
		self.updateZoomControl()
	}

	private func setupMapView() {
		self.view.backgroundColor = .systemBackground
		// Map
		let mapView = self.mapFactory.mapView
		mapView.showsAPIVersion = true
		mapView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(mapView)

		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: view.topAnchor),
			mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])
	}

	private func setupControls() {
		// Setup segmented control
		self.segmentedControl.addTarget(self, action: #selector(self.segmentedControlChanged(_:)), for: .valueChanged)
		self.segmentedControl.selectedSegmentIndex = 1
		self.segmentedControl.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self.segmentedControl)
		NSLayoutConstraint.activate([
			self.segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
			self.segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		])

		// Setup zoom controls
		self.zoomControlContainer.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(self.zoomControlContainer)

		NSLayoutConstraint.activate([
			self.zoomControlContainer.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			self.zoomControlContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			self.zoomControlContainer.widthAnchor.constraint(equalToConstant: 48),
			self.zoomControlContainer.heightAnchor.constraint(equalToConstant: 100),
		])

		self.updateZoomControl()
	}

	private func updateZoomControl() {
		// Remove old subviews
		self.zoomControlContainer.subviews.forEach { $0.removeFromSuperview() }

		let zoomControl: UIView
		if self.viewModel.controlsType == .default {
			zoomControl = self.mapFactory.mapControlFactory.makeZoomControl()
		} else {
			zoomControl = CustomZoomControl(map: self.mapFactory.map)
		}

		zoomControl.translatesAutoresizingMaskIntoConstraints = false
		self.zoomControlContainer.addSubview(zoomControl)
		NSLayoutConstraint.activate([
			zoomControl.topAnchor.constraint(equalTo: self.zoomControlContainer.topAnchor),
			zoomControl.bottomAnchor.constraint(equalTo: self.zoomControlContainer.bottomAnchor),
			zoomControl.leadingAnchor.constraint(equalTo: self.zoomControlContainer.leadingAnchor),
			zoomControl.trailingAnchor.constraint(equalTo: self.zoomControlContainer.trailingAnchor),
		])
	}

	@objc private func segmentedControlChanged(_ sender: UISegmentedControl) {
		switch sender.selectedSegmentIndex {
		case 0:
			self.viewModel.controlsType = .default
		case 1:
			self.viewModel.controlsType = .custom
		default:
			break
		}
		self.updateZoomControl()
	}
}
