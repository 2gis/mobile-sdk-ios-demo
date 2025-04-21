import UIKit
import DGis

class MapViewMarkersDemoViewController: UIViewController {
	private let viewModel: MapViewMarkersDemoUIViewModel
	private let mapFactory: IMapFactory
	private let mapControlFactory: IMapControlFactory
	private let zoomControl: ZoomControl
	private let currentLocationControl: CurrentLocationControl
	private var mapView: any UIView & IMapView
	private var markerViewOverlay: any UIView & IMarkerViewOverlay

	init(
		viewModel: MapViewMarkersDemoUIViewModel,
		mapFactory: IMapFactory
	) {

		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.mapControlFactory = self.mapFactory.mapControlFactory

		self.zoomControl = self.mapControlFactory.makeZoomControl()
		self.currentLocationControl = self.mapControlFactory.makeCurrentLocationControl()
		
		self.mapView = self.mapFactory.mapView
		self.markerViewOverlay = self.mapFactory.markerViewOverlay
		
		self.mapView.showsAPIVersion = true
		self.mapView.addObjectTappedCallback(callback: .init(callback: { [viewModel = self.viewModel] objectInfo in
			viewModel.tap(objectInfo: objectInfo)
		}))
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
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
			self.mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])

		// Map controls

		[self.zoomControl, self.currentLocationControl].forEach {
			$0.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview($0)
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
			self.markerViewOverlay.rightAnchor.constraint(equalTo: self.mapView.rightAnchor)
		])

		self.viewModel.mapMarkerPresenter.setAddMarkerViewCallback { markerView in
			self.markerViewOverlay.add(markerView: markerView)
		}
		self.viewModel.mapMarkerPresenter.setRemoveMarkerViewCallback { markerView in
			self.markerViewOverlay.remove(markerView: markerView)
		}
	}
}
