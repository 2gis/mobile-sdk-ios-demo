import UIKit
import DGis

class MapControlsDemoViewController: UIViewController {
    private let mapFactory: IMapFactory
	private let mapControlsFactory: IMapUIControlsFactory
    private var mapView: UIView & IMapUIView
	private var viewModel: MapControlsDemoViewModel

    init(mapFactory: IMapFactory, viewModel: MapControlsDemoViewModel) {
        self.mapFactory = mapFactory
		self.mapControlsFactory = mapFactory.mapUIControlsFactory
		self.viewModel = viewModel
		self.mapView = mapFactory.mapUIView
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
		self.setupUI()
    }

    private func setupUI() {
		self.view.backgroundColor = .white
		self.mapView.showsAPIVersion = true
		self.mapView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(self.mapView)

        NSLayoutConstraint.activate([
			self.mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			self.mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        ])

        // Add Controls
		let indoorControl = self.mapControlsFactory.makeIndoorUIControl()
		let trafficControl = self.mapControlsFactory.makeTrafficUIControl()
		let zoomControl = self.mapControlsFactory.makeZoomUIControl()
		let compassControl = self.mapControlsFactory.makeCompassUIControl()
		let currentLocationControl = self.mapControlsFactory.makeCurrentLocationUIControl()

        [indoorControl, trafficControl, zoomControl, compassControl, currentLocationControl].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview($0)
        }

		NSLayoutConstraint.activate([
			indoorControl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
			indoorControl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			indoorControl.widthAnchor.constraint(equalToConstant: 38),
			indoorControl.heightAnchor.constraint(equalToConstant: 119)
		])

		NSLayoutConstraint.activate([
			trafficControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			trafficControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
			trafficControl.widthAnchor.constraint(equalToConstant: 48)
		])

		NSLayoutConstraint.activate([
			zoomControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			zoomControl.centerYAnchor.constraint(equalTo: view.centerYAnchor),
			zoomControl.widthAnchor.constraint(equalToConstant: 48),
			zoomControl.heightAnchor.constraint(equalToConstant: 102)
		])

		NSLayoutConstraint.activate([
			compassControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			compassControl.bottomAnchor.constraint(equalTo: currentLocationControl.topAnchor, constant: -10),
			compassControl.widthAnchor.constraint(equalToConstant: 48)
		])

		NSLayoutConstraint.activate([
			currentLocationControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
			currentLocationControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
			currentLocationControl.widthAnchor.constraint(equalToConstant: 48)
		])
    }
}

