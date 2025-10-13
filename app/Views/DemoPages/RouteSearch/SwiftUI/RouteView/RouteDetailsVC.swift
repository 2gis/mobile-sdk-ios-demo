import UIKit
import DGis

final class RouteDetailsVC: UIViewController {
	private let factory: INavigationUIViewFactory
	private let route: TrafficRoute
	private lazy var routeDetailsView: IRouteDetailsUIView = {
		self.factory.makeRouteDetailsUIView(self.route, startName: nil, finishName: nil)
	}()

	init(route: TrafficRoute, factory: INavigationUIViewFactory) {
		self.route = route
		self.factory = factory
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("Use init(route:factory:).")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.addSubview(self.routeDetailsView)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.routeDetailsView.frame = self.view.bounds
	}
}
