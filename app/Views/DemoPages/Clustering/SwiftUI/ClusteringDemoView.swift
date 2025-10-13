import SwiftUI
import DGis

struct ClusteringDemoView: View {
	@ObservedObject private var viewModel: ClusteringDemoViewModel
	private let mapFactory: IMapFactory

	init(
		viewModel: ClusteringDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack {
			ZStack(alignment: .bottom) {
				ZStack(alignment: .trailing) {
					self.mapFactory.mapView
						.copyrightAlignment(.bottomLeft)
						.objectTappedCallback(callback: .init(
							callback: { [viewModel = self.viewModel] objectInfo in
								viewModel.tap(objectInfo: objectInfo)
							}
						))
						.objectLongPressCallback(callback: .init(
							callback: { [viewModel = self.viewModel] objectInfo in
								viewModel.tap(objectInfo: objectInfo)
							}
						))
						.edgesIgnoringSafeArea(.all)
					VStack {
						Spacer()

						self.mapFactory.mapViewsFactory.makeZoomView()

						Spacer()
					}
				}
				VStack {
					HStack {
						Spacer()
						self.settingsButton()
							.frame(width: 100, height: 100)
							.transition(.move(edge: .bottom))
							.animation(.easeInOut)
					}
					if self.viewModel.showMapObjectsMenu {
						self.makeMenu()
							.transition(.move(edge: .bottom))
							.animation(.easeInOut)
					}
				}
				if let cardViewModel = viewModel.selectedClusterCardViewModel {
					ClusterCardView(viewModel: cardViewModel)
						.transition(.move(edge: .bottom))
						.animation(.easeInOut)
				}
			}
			.sheet(isPresented: self.$viewModel.showDetailsSettings) {
				ClusteringSettingsView(
					isPresented: self.$viewModel.showDetailsSettings,
					groupingType: self.$viewModel.groupingType,
					mapObjectType: self.$viewModel.mapObjectType,
					animationIndex: self.$viewModel.animationIndex,
					objectsCount: self.$viewModel.objectsCount,
					groupingWidth: self.$viewModel.groupingWidth,
					minZoom: self.$viewModel.minZoom,
					maxZoom: self.$viewModel.maxZoom,
					isVisible: self.$viewModel.isVisible,
					isMapObjectsVisible: self.$viewModel.isMapObjectsVisible,
					useTextInCluser: self.$viewModel.useTextInCluster
				)
			}
			.navigationBarItems(trailing: self.detailsSettingsButton())
			.alert(isPresented: self.$viewModel.isErrorAlertShown) {
				Alert(title: Text(self.viewModel.errorMessage ?? ""))
			}
		}
	}
	
	private func makeMenu() -> some View {
		VStack(spacing: 12.0) {
			DetailsActionView(action: {
				self.viewModel.addMapObjects()
			}, primaryText: "Add specified number of map objects")
			DetailsActionView(action: {
				self.viewModel.removeMapObjects()
			}, primaryText: "Remove specified number of map objects")
			DetailsActionView(action: {
				self.viewModel.removeAndAddMapObjects()
			}, primaryText: "Remove and add specified number of map objects")
			DetailsActionView(action: {
				self.viewModel.moveAllMapObjects()
			}, primaryText: "Move all map objects")
			DetailsActionView(action: {
				self.viewModel.reinitMapObjectManager()
			}, primaryText: "Create new MapObjectManager")
			DetailsActionView(action: {
				self.viewModel.moveObjectsAndDeleteThem()
			}, primaryText: "Remove polyline and marker")
			DetailsActionView(action: {
				self.viewModel.removeAll()
			}, primaryText: "Remove all map objects")
		}
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "list.bullet") {
			self.viewModel.showMapObjectsMenu.toggle()
		}
	}

	private func detailsSettingsButton() -> some View {
		Button {
			self.viewModel.showDetailsSettings = true
		} label: {
			Image(systemName: "gear")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 30)
		}
	}
}
