import DGis
import SwiftUI

struct RouteSearchDemoView: View {
	@ObservedObject private var viewModel: RouteSearchDemoViewModel
	private let mapFactory: IMapFactory

	init(
		viewModel: RouteSearchDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack {
			self.mapFactory.mapView
				.copyrightAlignment(.bottomLeft)
			if self.viewModel.showRoutes {
				HStack {
					Spacer()
					Image(systemName: "multiply")
						.font(Font.system(size: 20, weight: .bold))
						.foregroundColor(.red)
						.shadow(radius: 3, x: 1, y: 1)
					Spacer()
				}
				RouteView(
					viewModel: RouteViewModel(
						transportType: self.viewModel.transportType,
						carRouteSearchOptions: self.viewModel.carRouteSearchOptions,
						publicTransportRouteSearchOptions: self.viewModel.publicTransportRouteSearchOptions,
						truckRouteSearchOptions: self.viewModel.truckRouteSearchOptions,
						taxiRouteSearchOptions: self.viewModel.taxiRouteSearchOptions,
						bicycleRouteSearchOptions: self.viewModel.bicycleRouteSearchOptions,
						pedestrianRouteSearchOptions: self.viewModel.pedestrianRouteSearchOptions,
						sourceFactory: self.viewModel.sourceFactory,
						routeEditorSourceFactory: self.viewModel.routeEditorSourceFactory,
						routeEditorFactory: self.viewModel.routeEditorFactory,
						map: self.mapFactory.map,
						feedbackGenerator: self.viewModel.feedbackGenerator,
						navigationViewFactory: self.viewModel.navigationUIViewFactory
					),
					show: self.$viewModel.showRoutes
				)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else {
				HStack {
					Spacer()
					VStack {
						Spacer()
						VStack(alignment: .trailing) {
							self.searchRouteButton()
								.padding(.bottom, 10)
							self.settingsButton()
						}
						.padding(.bottom, 40)
						.padding(.trailing, 20)
					}
				}
			}
			HStack {
				if self.viewModel.transportType == .pedestrian {
					self.mapFactory.mapViewsFactory.makeIndoorView()
						.frame(width: 38, height: 119)
						.fixedSize()
						.padding(.leading, 20)
				}
				Spacer()
				VStack {
					self.mapFactory.mapViewsFactory.makeZoomView()
						.frame(width: 48, height: 102)
						.fixedSize()
						.padding(20)
					self.mapFactory.mapViewsFactory.makeCurrentLocationView()
						.frame(width: 48, height: 48)
						.fixedSize()
						.padding(20)
				}
			}
		}
		.edgesIgnoringSafeArea(.bottom)
		.sheet(isPresented: self.$viewModel.showSettings) {
			RouteSearchSettingsView(
				shown: self.$viewModel.showSettings,
				transportType: self.$viewModel.transportType,
				carRouteSearchOptions: self.$viewModel.carRouteSearchOptions,
				publicTransportRouteSearchOptions: self.$viewModel.publicTransportRouteSearchOptions,
				truckRouteSearchOptions: self.$viewModel.truckRouteSearchOptions,
				taxiRouteSearchOptions: self.$viewModel.taxiRouteSearchOptions,
				bicycleRouteSearchOptions: self.$viewModel.bicycleRouteSearchOptions,
				pedestrianRouteSearchOptions: self.$viewModel.pedestrianRouteSearchOptions
			)
		}
	}

	private func searchRouteButton() -> some View {
		Button(action: {
			self.viewModel.showRoutes = true
		}) {
			HStack {
				Text(self.viewModel.transportType.name)
					.fontWeight(.bold)
				Image(systemName: self.viewModel.transportType.iconName)
					.frame(width: 40, height: 40, alignment: .center)
					.background(
						Circle()
							.fill(Color(UIColor.systemBackground))
					)
			}
		}
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "gear") {
			self.viewModel.showSettings = true
		}
	}
}

private extension TransportType {
	var iconName: String {
		switch self {
		case .publicTransport:
			return "bus.fill"
		case .bicycle:
			return "bicycle"
		case .pedestrian:
			return "figure.walk"
		case .car, .taxi, .truck:
			return "car.fill"
		@unknown default:
			assertionFailure("Unknown type: \(self)")
			return "Unknown \(self.rawValue)"
		}
	}
}
