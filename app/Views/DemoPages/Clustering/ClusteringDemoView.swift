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
				self.viewFactory.makeMapViewWithZoomControl(alignment: .bottomLeft)
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
		}
		.edgesIgnoringSafeArea(.all)
	}
}
