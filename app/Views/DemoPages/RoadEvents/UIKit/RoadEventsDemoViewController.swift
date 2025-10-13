import Combine
import DGis
import UIKit

class RoadEventsDemoViewController: UIViewController, RoadEventsFilterViewControllerDelegate {
	private let viewModel: RoadEventsDemoViewModel
	private let mapFactory: IMapFactory
	private let roadEventUIViewFactory: IRoadEventUIViewFactory
	private let mapControlsFactory: IMapUIControlsFactory
	private let zoomControl: ZoomUIControl
	private let currentLocationControl: CurrentLocationUIControl
	private let createRoadEventControl: RoadEventCreatorButtonUIControl
	private let createRoadEventUIView: IRoadEventCreatorUIView

	private var roadEventInfoView: IRoadEventInfoUIView?
	private var cancellables = Set<AnyCancellable>()

	init(
		viewModel: RoadEventsDemoViewModel,
		mapFactory: IMapFactory,
		roadEventUIViewFactory: IRoadEventUIViewFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.roadEventUIViewFactory = roadEventUIViewFactory
		self.mapControlsFactory = self.mapFactory.mapUIControlsFactory

		self.zoomControl = self.mapControlsFactory.makeZoomUIControl()
		self.currentLocationControl = self.mapControlsFactory.makeCurrentLocationUIControl()
		self.createRoadEventControl = self.mapControlsFactory.makeRoadEventCreatorButtonUIControl()
		self.createRoadEventUIView = self.roadEventUIViewFactory.makeRoadEventCreatorUIView(map: self.mapFactory.map)

		super.init(nibName: nil, bundle: nil)

		self.setupBindings()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.setupUI()

		self.navigationItem.rightBarButtonItem = UIBarButtonItem(
			image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
			style: .plain,
			target: self,
			action: #selector(self.showFilterView)
		)
	}

	private func setupBindings() {
		self.createRoadEventUIView.createRoadEventRequestCallback = { [weak self] result in
			self?.viewModel.handle(result)
		}
		self.createRoadEventUIView.cancelButtonCallback = { [weak self] in
			self?.viewModel.hideRoadEventForm()
		}
		self.createRoadEventUIView.visibleAreaEdgeInsetsChangedCallback = { [weak self] _ in
			self?.updateCameraPaddings()
		}

		self.viewModel.$isRoadEventFormPresented
			.receive(on: RunLoop.main)
			.sink { [weak self] isPresented in
				self?.presentRoadEventForm(isPresented)
			}.store(in: &self.cancellables)

		self.viewModel.$selectedRoadEvent
			.receive(on: RunLoop.main)
			.sink { [weak self] event in
				self?.presentRoadEventInfo(event)
			}.store(in: &self.cancellables)

		self.viewModel.$isAlertShowing
			.receive(on: RunLoop.main)
			.sink { [weak self] isShowing in
				self?.presentAlert(isShowing)
			}.store(in: &self.cancellables)
	}

	private func updateCameraPaddings() {
		guard let scale = self.createRoadEventUIView.window?.screen.nativeScale else { return }
		var insets: UIEdgeInsets = .zero
		if !self.createRoadEventUIView.isHidden {
			insets = self.createRoadEventUIView.visibleAreaEdgeInsets
		} else if let roadEventInfoView = self.roadEventInfoView {
			insets.bottom = roadEventInfoView.frame.height
		}
		let padding = Padding(
			left: UInt32(insets.left * scale),
			top: UInt32(insets.top * scale),
			right: UInt32(insets.right * scale),
			bottom: UInt32(insets.bottom * scale)
		)
		self.viewModel.map.camera.padding = padding
	}

	private func presentRoadEventForm(_ isPresented: Bool) {
		self.navigationController?.setNavigationBarHidden(isPresented, animated: true)
		let controls = [self.zoomControl, self.currentLocationControl, self.createRoadEventControl]
		controls.forEach { $0.isHidden = isPresented }
		self.createRoadEventUIView.isHidden = !isPresented
	}

	private func presentRoadEventInfo(_ event: RoadEvent?) {
		guard let event = event else {
			self.roadEventInfoView?.isHidden = true
			return
		}

		if self.roadEventInfoView == nil {
			let infoView = self.roadEventUIViewFactory.makeRoadEventInfoUIView(event)
			infoView.closeButtonCallback = { [weak self] in
				self?.viewModel.hideRoadEvent()
			}
			infoView.roadEventActionResultCallback = { [weak self] result in
				self?.viewModel.handle(result)
			}
			infoView.removeRoadEventActionResultCallback = { [weak self] result in
				self?.viewModel.handle(result)
			}
			infoView.translatesAutoresizingMaskIntoConstraints = false
			self.view.addSubview(infoView)
			self.roadEventInfoView = infoView

			NSLayoutConstraint.activate([
				infoView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
				infoView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
				infoView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			])
		} else {
			self.roadEventInfoView?.isHidden = false
			self.roadEventInfoView?.setRoadEvent(event)
		}
	}

	private func presentAlert(_ isShowing: Bool) {
		guard isShowing, let message = self.viewModel.alertMessage else {
			return
		}
		let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default) { [weak self] _ in
			self?.viewModel.isAlertShowing = false
		})
		present(alert, animated: true)
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

private extension RoadEventsDemoViewController {
	private func setupUI() {
		let mapView = self.mapFactory.mapUIView
		mapView.addObjectTappedCallback(callback: .init(
			callback: { [viewModel = self.viewModel] objectInfo in
				viewModel.tap(objectInfo: objectInfo)
			}
		))
		mapView.showsAPIVersion = true
		mapView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(mapView)

		NSLayoutConstraint.activate([
			mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
			mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
			mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
		])

		self.view.addSubview(self.createRoadEventUIView)
		self.createRoadEventUIView.translatesAutoresizingMaskIntoConstraints = false
		NSLayoutConstraint.activate([
			self.createRoadEventUIView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.createRoadEventUIView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			self.createRoadEventUIView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			self.createRoadEventUIView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
		])
		self.createRoadEventUIView.isHidden = true

		self.createRoadEventControl.addTarget(self, action: #selector(self.createRoadEvent), for: .touchUpInside)

		for item in [self.zoomControl, self.currentLocationControl, self.createRoadEventControl] {
			item.translatesAutoresizingMaskIntoConstraints = false
			view.addSubview(item)
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
			self.createRoadEventControl.heightAnchor.constraint(equalToConstant: 48),
		])
	}
}
