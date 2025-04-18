import SwiftUI
import DGis

struct MinimapDemoView: View {
	@Environment(\.presentationMode) private var presentationMode

	private enum Constants {
		static let miniMapTheme = Theme(name: "night")
		static let miniMapOpacity: CGFloat = 0.8
	}
	@ObservedObject private var viewModel: MinimapDemoViewModel
	private let miniMapSize: CGFloat = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 3
	private let mapFactory: IMapFactory
	private let miniMapFactory: IMapFactory
	private let targetMiniMapFactory: IMapFactory

	init(
		viewModel: MinimapDemoViewModel,
		mapFactory: IMapFactory,
		miniMapFactory: IMapFactory,
		targetMiniMapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.miniMapFactory = miniMapFactory
		self.targetMiniMapFactory = targetMiniMapFactory
	}

	var body: some View {
		ZStack(alignment: .top) {
			self.mapFactory.mapViewOverlay
				.mapViewOverlayCopyrightAlignment(.bottomRight)
				.mapViewOverlayShowsAPIVersion(true)
				.edgesIgnoringSafeArea(.all)
			self.makeStatusView()
			VStack {
				Spacer()
				self.mapFactory.mapControlViewFactory.makeZoomView()
				self.mapFactory.mapControlViewFactory.makeCurrentLocationView()
				Spacer()
			}
			.frame(maxWidth: .infinity, alignment: .trailing)
			VStack {
				Spacer()
				self.targetMiniMapFactory.mapViewOverlay
					.mapViewOverlayCopyrightAlignment(.bottomRight)
					.mapViewOverlayShowsAPIVersion(false)
					.mapViewOverlayAppearance(.universal(Constants.miniMapTheme))
					.frame(width: self.miniMapSize, height: self.miniMapSize)
					.clipShape(Circle())
					.opacity(Constants.miniMapOpacity)
					.shadow(color: Color(.black), radius: 2)
				Spacer()
				self.miniMapFactory.mapViewOverlay
					.mapViewOverlayCopyrightAlignment(.bottomRight)
					.mapViewOverlayShowsAPIVersion(false)
					.mapViewOverlayAppearance(.universal(Constants.miniMapTheme))
					.frame(width: self.miniMapSize, height: self.miniMapSize)
					.clipShape(Circle())
					.opacity(Constants.miniMapOpacity)
					.shadow(color: Color(.black), radius: 2)
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
						Text("Route Searching")
						.fontWeight(.bold)
						.padding()
					}
					.background(
						RoundedRectangle(cornerRadius: 5)
						.fill(Color(.systemBackground))
					)
					Spacer()
				}
			case .error(let message):
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

		}
	}
	
	private var backButton : some View {
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
