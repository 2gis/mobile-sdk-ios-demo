import SwiftUI
import DGis

struct RouteView: View {
	@Binding var show: Bool
	@ObservedObject private var viewModel: RouteViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: RouteViewModel,
		show: Binding<Bool>,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self._show = show
		self.viewFactory = viewFactory
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
					}, primaryText: "Set", detailsText: self.viewModel.pointADescription)
					DetailsActionView(action: {
						self.viewModel.setupPointB()
					}, primaryText: "Set", detailsText: self.viewModel.pointBDescription)
					if self.viewModel.shouldShowSearchRouteButton {
						DetailsActionView(action: {
							self.viewModel.findRoute()
						}, primaryText: "Find route")
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
						}, primaryText: "Remove route")
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
		.contentShape(Rectangle())
		.longPressAndDragRecognizer { state in
			self.viewModel.handleDragGesture(state)
		}
	}

	@ViewBuilder
	private func showStatusMessage() -> some View {
		switch self.viewModel.state {
			case .routesNotFound:
				Text("Routes not found")
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
				Text("Routes search...")
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
		let routePreviewListVC = self.viewFactory.makeRoutePreviewListVC(routesInfo: routeInfo)
		let navigationController = UINavigationController(rootViewController: routePreviewListVC)
		presenter.present(navigationController, animated: true, completion: nil)
		routePreviewListVC.onDidTapCancelButton = { [weak navigationController] in
			navigationController?.dismiss(animated: true, completion: nil)
		}
		routePreviewListVC.onDidSelectRoute = { [weak navigationController, factory = self.viewFactory] route in
			let viewController = factory.makeRouteDetailsVC(route: route)
			navigationController?.pushViewController(viewController, animated: true)
		}
	}
}
