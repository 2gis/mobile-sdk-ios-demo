import DGis
import SwiftUI

final class UIKitDemoFactory: RootViewFactory {
	func makeDemoPageUIView(_ page: DemoPage) throws -> UIViewController {
		switch page {
		case .customMapControls:
			try self.makeCustomMapControlsDemoPage()
		case .mapControls:
			try self.makeMapControlsDemoPage()
		case .mapInteraction:
			try self.makeMapInteractionDemoPage()
		case .mapViewMarkers:
			try self.makeMapViewMarkersDemoPage()
		case .roadEvents:
			try self.makeRoadEventsDemoPage()
		case .navigator:
			try self.makeNavigatorDemoPage()
		default: self.makeUnsupportedDemoPage()
		}
	}

	private func makeCustomMapControlsDemoPage() throws -> UIViewController {
		let viewModel = CustomMapControlsDemoViewModel()
		return try CustomMapControlsDemoViewController(
			viewModel: viewModel,
			mapFactory: self.makeMapFactory()
		)
	}

	private func makeMapControlsDemoPage() throws -> UIViewController {
		let mapFactory = try self.makeMapFactory()
		let viewModel = try MapControlsDemoViewModel(
			searchManager: self.makeSearchManager(),
			imageFactory: self.makeImageFactory(),
			map: mapFactory.map,
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService),
			logger: self.logger
		)
		return MapControlsDemoViewController(mapFactory: mapFactory, viewModel: viewModel)
	}

	private func makeMapInteractionDemoPage() throws -> UIViewController {
		MapInteractionDemoViewController(mapFactoryProvider: { try self.makeMapFactory() })
	}

	private func makeMapViewMarkersDemoPage() throws -> UIViewController {
		let mapFactory = try self.makeMapFactory()
		let viewModel = try MapViewMarkersDemoUIViewModel(
			searchManager: self.makeSearchManager(),
			map: mapFactory.map,
			mapMarkerPresenter: self.makeMapMarkerPresenter(),
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService),
			logger: self.logger
		)
		return MapViewMarkersDemoViewController(viewModel: viewModel, mapFactory: mapFactory)
	}

	private func makeRoadEventsDemoPage() throws -> UIViewController {
		let mapFactory = try self.makeMapFactory()
		let roadEventCardPresenter = RoadEventCardPresenter()
		let roadEventFormPresenter = RoadEventFormPresenter()
		let viewModel = RoadEventsDemoViewModel(
			map: mapFactory.map,
			mapSourceFactory: MapSourceFactory(context: self.context, settingsService: self.settingsService),
			roadEventCardPresenter: roadEventCardPresenter,
			roadEventFormPresenter: roadEventFormPresenter
		)
		let mapOverlayFactory = RoadEventsMapOverlayFactory(
			map: mapFactory.map,
			roadEventCardPresenter: roadEventCardPresenter,
			roadEventFormPresenter: roadEventFormPresenter,
			roadEventCardViewFactory: self.makeRoadEventCardViewFactory()
		)
		return RoadEventsDemoUIViewController(
			viewModel: viewModel,
			mapFactory: mapFactory,
			mapOverlayFactory: mapOverlayFactory
		)
	}

	func makeNavigatorDemoPage() throws -> UIViewController {
		let mapFactory = try self.makeMapFactory()
		let mapSourceFactory = MapSourceFactory(
			context: self.context,
			settingsService: self.settingsService
		)
		let viewModel = try NavigatorDemoViewModel(
			map: mapFactory.map,
			trafficRouter: TrafficRouter(context: self.context),
			navigationManager: NavigationManager(platformContext: self.context),
			locationService: LocationService(),
			voiceManager: self.sdk.voiceManager,
			applicationIdleTimerService: self.applicationIdleTimerService,
			navigatorSettings: self.navigatorSettings,
			mapSourceFactory: mapSourceFactory,
			settingsService: self.settingsService,
			logger: self.logger,
			imageFactory: self.makeImageFactory()
		)
		return NavigatorDemoViewController(
			mapFactory: mapFactory,
			viewModel: viewModel,
			navigationFactory: self.sdk.makeNavigationViewFactory
		)
	}

	private func makeUnsupportedDemoPage() -> UIViewController {
		let viewController = UIViewController()
		viewController.view.backgroundColor = .white

		let label = UILabel()
		label.text = "Unsupported demo page"
		label.textColor = .black
		label.textAlignment = .center
		label.font = UIFont.systemFont(ofSize: 20, weight: .bold)

		label.translatesAutoresizingMaskIntoConstraints = false
		viewController.view.addSubview(label)

		NSLayoutConstraint.activate([
			label.centerXAnchor.constraint(equalTo: viewController.view.centerXAnchor),
			label.centerYAnchor.constraint(equalTo: viewController.view.centerYAnchor),
		])

		return viewController
	}
}
