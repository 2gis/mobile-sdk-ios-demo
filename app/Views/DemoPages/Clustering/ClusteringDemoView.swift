import SwiftUI

struct ClusteringDemoView: View {
	@ObservedObject private var viewModel: ClusteringDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: ClusteringDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack {
			ZStack(alignment: .bottomTrailing) {
				self.viewFactory.makeMapViewWithZoomControl(alignment: .bottomLeft) { objectInfo in
					self.viewModel.tap(objectInfo: objectInfo)
				}
				self.settingsButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
				if self.viewModel.showMarkersMenu {
					VStack(spacing: 12.0) {
						DetailsActionView(action: {
							self.viewModel.addMarkers()
						}, primaryText: "Add specified number of markers")
						DetailsActionView(action: {
							self.viewModel.removeMarkers()
						}, primaryText: "Remove specified number of markers")
						DetailsActionView(action: {
							self.viewModel.removeAndAddMarkers()
						}, primaryText: "Remove and add specified number of markers")
						DetailsActionView(action: {
							self.viewModel.reinitMapObjectManager()
						}, primaryText: "Create new MapObjectManager")
						DetailsActionView(action: {
							self.viewModel.removeAll()
						}, primaryText: "Remove all markers")
					}
					.padding(.trailing, 40.0)
					.padding(.bottom, 60.0)
				}
				if let cardViewModel = viewModel.selectedClusterCardViewModel {
					self.viewFactory.makeClusterCardView(cardViewModel)
						.transition(.move(edge: .bottom))
				}
			}
			.sheet(isPresented: self.$viewModel.showDetailsSettings) {
				ClusteringSettingsView(
					isPresented: self.$viewModel.showDetailsSettings,
					groupingType: self.$viewModel.groupingType,
					objectsCount: self.$viewModel.markersCount,
					minZoom: self.$viewModel.minZoom,
					maxZoom: self.$viewModel.maxZoom,
					useLottie: self.$viewModel.useLottie,
					isVisible: self.$viewModel.isVisible
				)
			}
			.navigationBarItems(trailing: self.detailsSettingsButton())
			.alert(isPresented: self.$viewModel.isErrorAlertShown) {
				Alert(title: Text(self.viewModel.errorMessage ?? ""))
			}
		}
		.edgesIgnoringSafeArea(.all)
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "list.bullet") {
			self.viewModel.showMarkersMenu.toggle()
		}
		.padding(.bottom, 40)
		.padding(.trailing, 20)
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
