import SwiftUI
import DGis

struct RouteView: View {
	@Binding var show: Bool
	@ObservedObject private var viewModel: RouteViewModel

	init(
		viewModel: RouteViewModel,
		show: Binding<Bool>
	) {
		self.viewModel = viewModel
		self._show = show
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			VStack {
				HStack {
					Spacer()
					self.showStatusMessage()
					.padding(.top)
					Spacer()
				}
				Spacer()
			}
			HStack {
				VStack(spacing: 12.0) {
					Spacer()
					DetailsActionView(action: {
						self.viewModel.setupPointA()
					}, primaryText: "Set point A", detailsText: self.viewModel.pointADescription)
					DetailsActionView(action: {
						self.viewModel.setupPointB()
					}, primaryText: "Set point B", detailsText: self.viewModel.pointBDescription)
					if self.viewModel.transportType != .publicTransport {
						DetailsActionView(action: {
							self.viewModel.setupIntermediatePoint()
						}, primaryText: "Set intermediate point", detailsText: self.viewModel.intermediatePointsDescription)
					}
					if self.viewModel.shouldShowSearchRouteButton {
						DetailsActionView(action: {
							self.viewModel.findRoute()
						}, primaryText: "Calculate route")
					}
					if self.viewModel.showRouteListOption,
					   let routeInfo = self.viewModel.routeEditorRoutesInfo {
						DetailsActionView(action: {
							self.showRouteObjectList(routeInfo: routeInfo)
						}, primaryText: "Show routes list")
					}
					if self.viewModel.shouldShowRemoveRouteButton {
						DetailsActionView(action: {
							self.viewModel.removeRoute()
						}, primaryText: "Clear routes")
					}
					DetailsActionView(action: {
						self.show = false
					}, primaryText: "Close")
				}
				.padding([.leading], 40.0)
				.padding([.bottom], 60.0)
				Spacer()
			}
		}
		.longPressAndDragRecognizer { state in
			self.viewModel.handleDragGesture(state)
		}
	}

	@ViewBuilder
	private func showStatusMessage() -> some View {
		switch self.viewModel.state {
		case .routesNotFound:
			Text("Failed to find a route")
				.font(.headline)
				.foregroundColor(.red)
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 5)
						.fill(Color.white)
				)
		case .buildRoutePoints, .readyToSearch, .routesFound:
			EmptyView()
		case .routesSearch:
			Text("Searching for a route...")
				.font(.headline)
				.padding()
				.background(
					RoundedRectangle(cornerRadius: 5)
						.fill(Color.white)
				)
		}
	}

	private func showRouteObjectList(routeInfo: RouteEditorRoutesInfo) {
		guard let presenter = UIApplication.shared.keyWindow?.topViewController else { return }
		let routePreviewListVC = RoutePreviewListVC(routesInfo: routeInfo, factory: self.viewModel.navigationViewFactory)
		let navigationController = UINavigationController(rootViewController: routePreviewListVC)
		presenter.present(navigationController, animated: true, completion: nil)
		routePreviewListVC.onDidTapCancelButton = { [weak navigationController] in
			navigationController?.dismiss(animated: true, completion: nil)
		}
		routePreviewListVC.onDidSelectRoute = { [weak navigationController] route in
			let viewController = RouteDetailsVC(route: route, factory: self.viewModel.navigationViewFactory)
			navigationController?.pushViewController(viewController, animated: true)
		}
	}
}
