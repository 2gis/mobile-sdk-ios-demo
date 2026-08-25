import DGis
import SwiftUI

struct TerritoryManagerDemoView: View {
	private enum Constants {
		static let mapControlsPadding: CGFloat = 10
		static let backgroundPadding: CGFloat = 4
		static let cornerRadius: CGFloat = 8
		static let shadowRadius: CGFloat = 2
		static let scrollViewPadding: CGFloat = 4
		static let backgroundColor: SwiftUI.Color = .init(.systemBackground)
	}

	@ObservedObject private var viewModel: TerritoryManagerDemoViewModel
	@EnvironmentObject private var navigationService: NavigationService
	private let mapFactory: IMapFactory
	private let mapViewsFactory: IMapViewsFactory

	init(
		viewModel: TerritoryManagerDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.mapViewsFactory = mapFactory.mapViewsFactory
	}

	var body: some View {
		ZStack {
			self.mapFactory.mapView
				.copyrightAlignment(.bottomLeft)
				.edgesIgnoringSafeArea(.all)
			VStack {
				self.mapControlsView
					.padding(.horizontal, Constants.mapControlsPadding)
				self.viewportTerritoriesView
			}
		}
		.navigationBarItems(trailing: self.listViewBtton)
	}

	private var listViewBtton: some View {
		Button(
			action: { self.navigationService.present(TerritoryManagerListView(viewModel: self.viewModel)) },
			label: { Image(systemName: "list.dash") }
		)
		.padding(Constants.backgroundPadding)
		.background(
			RoundedRectangle(cornerRadius: Constants.cornerRadius)
				.fill(Constants.backgroundColor)
				.shadow(radius: Constants.shadowRadius)
		)
	}

	private var mapControlsView: some View {
		VStack {
			Spacer()
			HStack {
				self.mapViewsFactory.makeIndoorView()
				Spacer()
				self.mapViewsFactory.makeZoomView()
			}
			Spacer()
			HStack {
				Spacer()
				self.mapViewsFactory.makeCompassView()
			}
			HStack {
				Spacer()
				self.mapViewsFactory.makeCurrentLocationView()
			}
		}
	}

	private var viewportTerritoriesView: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack {
				ForEach(self.viewModel.viewportTerritories, id: \.id) { item in
					TerritoryView(viewModel: item)
						.padding(Constants.backgroundPadding)
						.background(
							RoundedRectangle(cornerRadius: Constants.cornerRadius)
								.fill(Constants.backgroundColor)
								.shadow(radius: Constants.shadowRadius)
						)
				}
			}
			.padding(Constants.scrollViewPadding)
		}
	}
}
