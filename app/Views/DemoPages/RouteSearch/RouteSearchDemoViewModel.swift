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

	private let map: Map

	init(map: Map, mapSourceFactory: IMapSourceFactory) {
		self.map = map

		let source = mapSourceFactory.makeMyLocationMapObjectSource(directionBehaviour: .followSatelliteHeading)
		map.addSource(source: source)
	}
}
