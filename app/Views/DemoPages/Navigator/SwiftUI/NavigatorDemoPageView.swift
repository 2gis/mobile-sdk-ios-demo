import SwiftUI
import DGis

struct NavigatorDemoView: View {
	private enum Constants {
		static let offset: CGFloat = 10
		static let buttonSize: CGFloat = 44
		static let pickerHeight: CGFloat = 44
		static let pickerWidth: CGFloat = 150
		static let closeMenuHeight: CGFloat = 100
		static let closeMenuWidth: CGFloat = 272
		static let closeMenuButtonsOffset: CGFloat = -8
		static let closeMenuButtonsHeight: CGFloat = 46
		static let closeMenuTitleHeight: CGFloat = 54
	}

	@Environment(\.colorScheme) var colorScheme
	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject private var viewModel: NavigatorDemoViewModel

	private let mapFactory: IMapFactory
	private let mapControlViewFactory: IMapControlViewFactory
	private let navigatorViewFactory: INavigatorViewFactory

	init(
		viewModel: NavigatorDemoViewModel,
		mapFactory: IMapFactory,
		navigatorViewFactory: INavigatorViewFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.mapControlViewFactory = mapFactory.mapControlViewFactory
		self.navigatorViewFactory = navigatorViewFactory
	}

	var body: some View {
		ZStack {
			self.mapFactory.mapViewOverlay
				.mapViewOverlayObjectTappedCallback(callback: .init(callback: { [viewModel = self.viewModel] objectInfo in
					viewModel.tap(objectInfo) }))
				.mapViewOverlayObjectLongPressCallback(callback: .init(callback: { [viewModel = self.viewModel] objectInfo in
					viewModel.longPress(objectInfo)}))
				.edgesIgnoringSafeArea(.all)
			self.navigatorViewFactory.makeNavigationView(
				map: self.mapFactory.map,
				navigationManager: self.viewModel.navigationManager
			)
			.navigatorViewFinishButtonCallback({ [viewModel = self.viewModel] in
				viewModel.stopNavigation()
			})
			if self.viewModel.showTargetPointPicker {
				HStack {
					self.mapControlViewFactory.makeIndoorView()
						.frame(width: 38, height: 119)
						.fixedSize()
						.padding(.leading, 20)
					Spacer()
				}
				HStack {
					Spacer()
					VStack {
						self.mapControlViewFactory.makeZoomView()
							.frame(width: 48, height: 102)
							.fixedSize()
							.padding(20)
						self.mapControlViewFactory.makeCurrentLocationView()
							.frame(width: 48, height: 48)
							.fixedSize()
					}
				}
				self.targetPointSearchOverlay()
			}

			if self.viewModel.showRouteSearchMessage {
				Text("Route search...")
				.fontWeight(.bold)
			}
			if self.viewModel.isStopNavigationButtonVisible {
				VStack(alignment: .leading) {
					Spacer()
					HStack {
						self.closeButton()
						Spacer()
					}
					.padding([.leading, .bottom], 20)
				}
			}
			if self.viewModel.showCloseMenu {
				self.closeMenu()
			}
		}
		.onDisappear {
			self.viewModel.stopNavigation()
		}
		.navigationBarHidden(true)
		.navigationBarTitle("")
		.alert(isPresented: self.$viewModel.isErrorAlertShown) {
			Alert(title: Text(self.viewModel.errorMessage ?? ""))
		}
		.actionSheet(item: self.$viewModel.request, content: { request in
			switch request {
				case .routeSelection(let trafficRoutes):
					return self.routeSelectionActionSheet(trafficRoutes)
				case .addIntermediatePoint(let point):
					return self.addIntermediatePointActionSheet(point)
			}
		})
	}

	private func targetPointSearchOverlay() -> some View {
		NavigatorTargetPointSearchOverlayView(
			viewModel: self.viewModel.navigatorSettingsViewModel,
			startNavigationCallback: {
				[weak viewModel = self.viewModel] in
				viewModel?.state = .targetPointSearch
				viewModel?.startNavigation()
			},
			restoreNavigationCallback: {
				[weak viewModel = self.viewModel] in
				viewModel?.restoreNavigation()
			}
		)
	}

	private func closeButton() -> some View {
		return Button.makeCircleButton(iconName: "xmark") {
			self.stopNavigation()
			self.presentationMode.wrappedValue.dismiss()
		}
	}

	private func routeSelectionActionSheet(_ routes: [TrafficRoute]) -> ActionSheet {
		var buttons: [ActionSheet.Button] = routes.map { route in
			ActionSheet.Button.default(Text("\(route.description)")) {
				self.viewModel.select(route: route)
			}
		}
		buttons.append(
			.cancel {
				self.stopNavigation()
			}
		)
		return ActionSheet(
			title: Text("Which route will we take?"),
			buttons: buttons
		)
	}

	private func addIntermediatePointActionSheet(_ routePoint: RouteSearchPoint) -> ActionSheet {
		let actionSheetText = self.viewModel.isFreeRoam ? "Add a destination point?" : "Add an intermediate point?"
		return ActionSheet(
			title: Text(actionSheetText),
			buttons: [
				.default(Text("Submit")) {
					self.viewModel.addIntermediatePoint(routePoint: routePoint)
				},
				.cancel {
					self.viewModel.cancelAddIntermediatePoint()
				}
			]
		)
	}

	private func stopNavigation() {
		self.viewModel.stopNavigation()
	}

	private func closeMenu() -> some View {
		ZStack {
			Color.black
				.edgesIgnoringSafeArea(.all)
				.opacity(0.7)
			VStack {
				Text("Back to Home page?")
					.foregroundColor(.primary)
					.fontWeight(.bold)
					.padding(.top, -Constants.closeMenuButtonsOffset)
					.multilineTextAlignment(.center)
					.frame(height: Constants.closeMenuTitleHeight)

				Divider()

				HStack {
					Button(action: {
						self.presentationMode.wrappedValue.dismiss()
					}) {
						Text("Yes")
							.fontWeight(.medium)
							.foregroundColor(.closeMenuActionButtons)
							.padding(.leading, -Constants.closeMenuButtonsOffset)
							.frame(maxWidth: .infinity)
							.multilineTextAlignment(.center)
					}

					Divider()

					Button(action: {
						self.viewModel.showCloseMenu = false
					}) {
						Text("No")
							.fontWeight(.medium)
							.foregroundColor(.closeMenuActionButtons)
							.padding(.trailing, -Constants.closeMenuButtonsOffset)
							.frame(maxWidth: .infinity)
							.multilineTextAlignment(.center)
					}
				}
				.frame(height: Constants.closeMenuButtonsHeight)
				.padding(.top, Constants.closeMenuButtonsOffset)
			}
			.background(Color(.systemBackground))
			.cornerRadius(16)
			.shadow(radius: 3)
			.frame(width: Constants.closeMenuWidth, height: Constants.closeMenuHeight)
		}
	}
}
