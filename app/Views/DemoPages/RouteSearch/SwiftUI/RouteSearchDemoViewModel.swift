import SwiftUI
import Combine
import DGis

final class RouteSearchDemoViewModel: ObservableObject {
	@Published var showRoutes: Bool = false
	@Published var showSettings: Bool = false
	@Published var transportType: TransportType = .car
	@Published var carRouteSearchOptions: CarRouteSearchOptions = .init()
	@Published var publicTransportRouteSearchOptions: PublicTransportRouteSearchOptions = .init()
	@Published var truckRouteSearchOptions: TruckRouteSearchOptions = .init(car: .init())
	@Published var taxiRouteSearchOptions: TaxiRouteSearchOptions = .init(car: .init())
	@Published var bicycleRouteSearchOptions: BicycleRouteSearchOptions = .init()
	@Published var pedestrianRouteSearchOptions: PedestrianRouteSearchOptions = .init()
	let sourceFactory: () -> ISourceFactory
	let routeEditorSourceFactory: (RouteEditor) -> RouteEditorSource
	let routeEditorFactory: () -> RouteEditor
	let feedbackGenerator: FeedbackGenerator
	let navigationViewFactory: INavigationViewFactory

	private let map: Map

	init(
		map: Map,
		mapSourceFactory: IMapSourceFactory,
		sourceFactory: @escaping () -> ISourceFactory,
		routeEditorSourceFactory: @escaping (RouteEditor) -> RouteEditorSource,
		routeEditorFactory: @escaping () -> RouteEditor,
		feedbackGenerator: FeedbackGenerator,
		navigationViewFactory: INavigationViewFactory
	) {
		self.map = map
		self.sourceFactory = sourceFactory
		self.routeEditorSourceFactory = routeEditorSourceFactory
		self.routeEditorFactory = routeEditorFactory
		self.feedbackGenerator = feedbackGenerator
		self.navigationViewFactory = navigationViewFactory

		let source = mapSourceFactory.makeMyLocationMapObjectSource(bearingSource: .satellite)
		map.addSource(source: source)
	}
}
