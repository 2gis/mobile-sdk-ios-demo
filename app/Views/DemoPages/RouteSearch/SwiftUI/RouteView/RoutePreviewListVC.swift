import UIKit
import DGis

final class RoutePreviewListVC: UIViewController {
	var onDidTapCancelButton: (() -> Void)?
	var onDidSelectRoute: ((TrafficRoute) -> Void)?
	private let factory: INavigationViewFactory
	private let routesInfo: RouteEditorRoutesInfo
	private lazy var routeListView: IRouteListView = {
		self.factory.makeRouteListView(self.routesInfo.routes)
	}()

	init(routesInfo: RouteEditorRoutesInfo, factory: INavigationViewFactory) {
		self.routesInfo = routesInfo
		self.factory = factory
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("Use init(routesInfo:factory:).")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubview(self.routeListView)
		self.navigationItem.leftBarButtonItem = .init(
			barButtonSystemItem: .cancel,
			target: self,
			action: #selector(self.cancelButtonTapped)
		)
		self.routeListView.trafficRouteSelectedCallback = { [weak self] route in
			self?.onDidSelectRoute?(route)
		}
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.routeListView.frame = self.view.bounds
	}

	@objc private func cancelButtonTapped() {
		self.onDidTapCancelButton?()
	}
}
