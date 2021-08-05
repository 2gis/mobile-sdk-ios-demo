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
				self.viewFactory.makeMapView(alignment: .bottomLeft) { location in
					self.viewModel.tap(location)
				}
				self.settingsButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
				if self.viewModel.showMarkersMenu {
					VStack(spacing: 12.0) {
						VStack {
							Text("Число добавляемых или удаляемых маркеров")
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
						}, primaryText: "Добавить заданное число маркеров")
						DetailsActionView(action: {
							self.viewModel.removeMarkers()
						}, primaryText: "Удалить заданное число маркеров")
						DetailsActionView(action: {
							self.viewModel.removeAll()
						}, primaryText: "Удалить все маркеры")
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
