import DGis
import UIKit

class MapViewMarkersDemoViewController: UIViewController {
	private let viewModel: MapViewMarkersDemoUIViewModel
	private let mapFactory: IMapFactory
	private let mapControlsFactory: IMapUIControlsFactory
	private let zoomControl: ZoomUIControl
	private let currentLocationControl: CurrentLocationUIControl
	private var mapView: any UIView & IMapUIView
	private var markerViewOverlay: any UIView & IMarkerOverlayUIView

	init(
		viewModel: MapViewMarkersDemoUIViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.mapControlsFactory = self.mapFactory.mapUIControlsFactory

		self.zoomControl = self.mapControlsFactory.makeZoomUIControl()
		self.currentLocationControl = self.mapControlsFactory.makeCurrentLocationUIControl()

		self.mapView = self.mapFactory.mapUIView
		self.markerViewOverlay = self.mapFactory.markerOverlayUIView

		self.mapView.showsAPIVersion = true
		self.mapView.addObjectTappedCallback(callback: .init(callback: { [viewModel = self.viewModel] objectInfo in
			Task { @MainActor in
				viewModel.tap(objectInfo: objectInfo)
			}
		}))
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()
		self.setUpMarkerViewOverlay()
	}

	private func setupUI() {
		self.view.backgroundColor = .systemBackground

		// Map
		self.mapView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(self.mapView)

		NSLayoutConstraint.activate([
			self.mapView.topAnchor.constraint(equalTo: view.topAnchor),
			self.mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			self.mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			self.mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
		])

		// Map controls

		for item in [self.zoomControl, self.currentLocationControl] {
			item.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(item)
		}

		NSLayoutConstraint.activate([
			self.zoomControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			self.zoomControl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			self.zoomControl.widthAnchor.constraint(equalToConstant: 48),
			self.zoomControl.heightAnchor.constraint(equalToConstant: 102),

			self.currentLocationControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			self.currentLocationControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
			self.currentLocationControl.widthAnchor.constraint(equalToConstant: 48),
			self.currentLocationControl.heightAnchor.constraint(equalToConstant: 48),
		])
	}

	private func setUpMarkerViewOverlay() {
		self.markerViewOverlay.translatesAutoresizingMaskIntoConstraints = false
		self.mapView.addSubview(self.markerViewOverlay)
		NSLayoutConstraint.activate([
			self.markerViewOverlay.topAnchor.constraint(equalTo: self.mapView.topAnchor),
			self.markerViewOverlay.leftAnchor.constraint(equalTo: self.mapView.leftAnchor),
			self.markerViewOverlay.bottomAnchor.constraint(equalTo: self.mapView.bottomAnchor),
			self.markerViewOverlay.rightAnchor.constraint(equalTo: self.mapView.rightAnchor),
		])

		self.viewModel.mapMarkerPresenter.setAddMarkerViewCallback { [weak self] markerView in
			self?.markerViewOverlay.add(markerView: markerView)
		}
		self.viewModel.mapMarkerPresenter.setRemoveMarkerViewCallback { [weak self] markerView in
			self?.markerViewOverlay.remove(markerView: markerView)
		}
	}
}
