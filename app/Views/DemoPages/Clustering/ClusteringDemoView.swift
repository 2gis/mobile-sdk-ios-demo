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
						VStack {
							Text("Number of markers added or removed")
							.font(.caption)
							.foregroundColor(.gray)
							TextField("", text: self.$viewModel.markersCount)
							.frame(width: 50, height: 20, alignment: .center)
							.keyboardType(.numberPad)
						}
						.background(
							RoundedRectangle(cornerRadius: 6)
							.scale(1.2)
							.fill(Color.white)
						)
						DetailsActionView(action: {
							self.viewModel.addMarkers()
						}, primaryText: "Add specified number of markers")
						DetailsActionView(action: {
							self.viewModel.removeMarkers()
						}, primaryText: "Remove specified number of markers")
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
}
