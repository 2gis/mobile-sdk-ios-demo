import DGis
import SwiftUI

struct MinimapDemoView: View {
	@Environment(\.presentationMode) private var presentationMode

	private enum Constants {
		static let miniMapOpacity: CGFloat = 0.8
	}

	@ObservedObject private var viewModel: MinimapDemoViewModel
	private let miniMapSize: CGSize = .init(width: 140, height: 140)
	private let mapFactory: IMapFactory
	private let miniMapFactory: IMapFactory
	private let targetMiniMapFactory: IMapFactory
	private let mapViewsFactory: IMapViewsFactory
	private let miniMapViewModel: NavigationMiniMapViewModel

	init(
		viewModel: MinimapDemoViewModel,
		mapFactory: IMapFactory,
		miniMapFactory: IMapFactory,
		targetMiniMapFactory: IMapFactory
	) throws {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.miniMapFactory = miniMapFactory
		self.targetMiniMapFactory = targetMiniMapFactory
		self.mapViewsFactory = mapFactory.mapViewsFactory
		self.miniMapViewModel = try NavigationMiniMapViewModel(
			navigationManager: viewModel.navigationManager,
			mapFactory: self.miniMapFactory
		)
	}

	var body: some View {
		ZStack(alignment: .top) {
			self.mapFactory.mapView
				.copyrightAlignment(.bottomRight)
				.showsAPIVersion(true)
				.edgesIgnoringSafeArea(.all)
			self.makeStatusView()
			VStack {
				Spacer()
				self.mapViewsFactory.makeZoomView()
				self.mapViewsFactory.makeCurrentLocationView()
				Spacer()
			}
			.frame(maxWidth: .infinity, alignment: .trailing)
			VStack {
				Spacer()
				try! self.mapViewsFactory.makeMiniMapView(mapFactory: self.targetMiniMapFactory)
					.frame(width: self.miniMapSize.width, height: self.miniMapSize.height)
					.opacity(Constants.miniMapOpacity)
					.shadow(radius: 2)
				Spacer()
				NavigationMiniMapView(viewModel: self.miniMapViewModel)
					.frame(width: self.miniMapSize.width, height: self.miniMapSize.height)
			}
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.onAppear {
			self.viewModel.startNavigation()
		}
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: self.backButton)
	}

	@ViewBuilder
	private func makeStatusView() -> some View {
		switch self.viewModel.state {
		case .navigation, .initial:
			EmptyView()
		case .routeSearch:
			VStack {
				HStack {
					Text("Route searching")
						.fontWeight(.bold)
						.padding()
				}
				.background(
					RoundedRectangle(cornerRadius: 5)
						.fill(Color(.systemBackground))
				)
				Spacer()
			}
		case let .error(message):
			VStack {
				VStack {
					Text(message)
						.fontWeight(.bold)
					Button {
						self.viewModel.startNavigation()
					} label: {
						Text("Try again")
							.fontWeight(.medium)
							.foregroundColor(.white)
							.padding()
					}
					.background(
						RoundedRectangle(cornerRadius: 5)
							.fill(Color(.red))
					)
				}
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 5)
						.fill(Color(.systemBackground))
				)
				Spacer()
			}
		@unknown default:
			fatalError("Unknown type: \(self.viewModel.state)")
		}
	}

	private var backButton: some View {
		Button(action: {
			self.viewModel.stopNavigation()
			self.presentationMode.wrappedValue.dismiss()
		}) {
			HStack {
				Image(systemName: "chevron.backward")
				Text("Back")
			}
		}
	}
}
