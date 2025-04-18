import UIKit
import CarPlay
import DGis

final class CarPlayController: UIViewController {
	private enum Constants {
		static let defaultCameraPosition = CameraPosition(
			point: GeoPoint(latitude: 54.9788616, longitude: 82.8965154),
			zoom: .init(value: 14),
			tilt: .init(value: 15),
			bearing: .init(value: 0)
		)
	}
	private let interfaceController: CPInterfaceController
	private lazy var carPlayGestureViewFactory = CarPlayGestureViewFactory(carPlayMapEventsProvider: carPlayMapEventsProvider)
	private lazy var mapOptions: MapOptions = {
		var options = MapOptions.default
		options.position = Constants.defaultCameraPosition
		options.gestureViewFactory = carPlayGestureViewFactory
		let nativeScale: Float = Float(view.window?.screen.nativeScale ?? 1)
		let ppi: Float = 60 * nativeScale + 10
		options.devicePPI = DevicePpi(value: ppi)
		options.deviceDensity = DeviceDensity(value: nativeScale)
		return options
	}()
	private lazy var carPlayMapEventsProvider = CarPlayMapEventsProvider()
	private lazy var mapFactory = try! Container.shared.sdk.makeMapFactory(options: self.mapOptions)
	private lazy var mapView: UIView & DGis.IMapView = mapFactory.mapView
	private lazy var mapTemplate: CPMapTemplate = {
		let mapTemplate = CPMapTemplate()
		let zoomInButton = CPMapButton.zoomIn(handler: { [weak self] button in
			self?.carPlayMapEventsProvider.zoomIn()
		})
		let zoomOutButton = CPMapButton.zoomOut(handler: { [weak self] button in
			self?.carPlayMapEventsProvider.zoomOut()
		})
		mapTemplate.mapButtons = [
			zoomInButton,
			zoomOutButton,
		]
		return mapTemplate
	}()
	private var isMapShown = false

	init(
		interfaceController: CPInterfaceController
	) {
		self.interfaceController = interfaceController
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.mapTemplate.automaticallyHidesNavigationBar = false
		self.interfaceController.setRootTemplate(mapTemplate, animated: false, completion: nil)
		self.view.addSubview(mapView)
		self.showMap()
	}

	func showMap() {
		guard !isMapShown else { return }
		self.isMapShown = true
		self.mapView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(mapView)
		NSLayoutConstraint.activate([
			self.mapView.topAnchor.constraint(equalTo: view.topAnchor),
			self.mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			self.mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			self.mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
		])
	}
}

extension CarPlayController: CPInterfaceControllerDelegate {}

final class CarPlayMapEventsProvider {
	var onZoomIn: (() -> Void)?
	var onZoomOut: (() -> Void)?

	func zoomIn() {
		onZoomIn?()
	}
	func zoomOut() {
		onZoomOut?()
	}
}

final class CarPlayGestureViewFactory: IMapGestureViewFactory {
	private let carPlayMapEventsProvider: CarPlayMapEventsProvider

	init(carPlayMapEventsProvider: CarPlayMapEventsProvider) {
		self.carPlayMapEventsProvider = carPlayMapEventsProvider
	}

	func makeGestureView(
		map: Map,
		eventProcessor: IMapEventProcessor,
		coordinateSpace: IMapCoordinateSpace
	) -> UIView & IMapGestureView {
		CarPlayGestureView(
			mapEventProcessor: eventProcessor,
			mapCoordinateSpace: coordinateSpace,
			carPlayMapEventsProvider: carPlayMapEventsProvider
		)
	}
}


final class CarPlayGestureView: UIView, IMapGestureView {
	private let mapEventProcessor: IMapEventProcessor
	private let mapCoordinateSpace: IMapCoordinateSpace
	private let carPlayMapEventsProvider: CarPlayMapEventsProvider

	init(
		mapEventProcessor: IMapEventProcessor,
		mapCoordinateSpace: IMapCoordinateSpace,
		carPlayMapEventsProvider: CarPlayMapEventsProvider
	) {
		self.mapEventProcessor = mapEventProcessor
		self.mapCoordinateSpace = mapCoordinateSpace
		self.carPlayMapEventsProvider = carPlayMapEventsProvider
		super.init(frame: .zero)

		carPlayMapEventsProvider.onZoomIn = { [weak self] in
			self?.mapEventProcessor.process(event: ScaleMapEvent(zoomDelta: 1))
		}
		carPlayMapEventsProvider.onZoomOut = { [weak self] in
			self?.mapEventProcessor.process(event: ScaleMapEvent(zoomDelta: -1))
		}
	}

	required init?(coder: NSCoder) {
		fatalError("Use init(mapEventProcessor:)")
	}
}

extension CPMapButton {
	static func zoomIn(handler: ((CPMapButton) -> Void)? = nil) -> CPMapButton {
		let button = CPMapButton(handler: handler)
		button.image = UIImage(systemName: "plus.circle.fill")
		button.focusedImage = UIImage(systemName: "plus.circle.fill")
		return button
	}

	static func zoomOut(handler: ((CPMapButton) -> Void)? = nil) -> CPMapButton {
		let button = CPMapButton(handler: handler)
		button.image = UIImage(systemName: "minus.circle.fill")
		button.focusedImage = UIImage(systemName: "minus.circle.fill")
		return button
	}
}
