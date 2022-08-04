import SwiftUI

struct RouteSearchDemoView: View {
	@ObservedObject private var viewModel: RouteSearchDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: RouteSearchDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack {
			self.viewFactory.makeMapView()

			if self.viewModel.showRoutes {
				HStack {
					Spacer()
					Image(systemName: "multiply")
					.font(Font.system(size: 20, weight: .bold))
					.foregroundColor(.red)
					.shadow(radius: 3, x: 1, y: 1)
					Spacer()
				}
				self.viewFactory.makeRouteView(
					show: self.$viewModel.showRoutes,
					transportType: self.viewModel.transportType,
					carRouteSearchOptions: self.viewModel.carRouteSearchOptions,
					publicTransportRouteSearchOptions: self.viewModel.publicTransportRouteSearchOptions,
					truckRouteSearchOptions: self.viewModel.truckRouteSearchOptions,
					taxiRouteSearchOptions: self.viewModel.taxiRouteSearchOptions,
					bicycleRouteSearchOptions: self.viewModel.bicycleRouteSearchOptions,
					pedestrianRouteSearchOptions: self.viewModel.pedestrianRouteSearchOptions
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
				Spacer()
				VStack {
					self.viewFactory.makeZoomControl()
						.frame(width: 48, height: 102)
						.fixedSize()
						.padding(20)
					self.viewFactory.makeCurrentLocationControl()
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
					.fill(.white)
					.shadow(radius: 3)
				)
			}
		}
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "gear", shadowRadius: 3) {
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
		}
	}
}
