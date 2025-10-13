import SwiftUI
import DGis

struct MultiViewPortsDemoView: View {
	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject private var viewModel: MultiViewPortsDemoViewModel
	private let firstMapFactory: IMapFactory
	private let secondMapFactory: IMapFactory

	init(
		viewModel: MultiViewPortsDemoViewModel,
		firstMapFactory: IMapFactory,
		secondMapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.firstMapFactory = firstMapFactory
		self.secondMapFactory = secondMapFactory
	}

	var body: some View {
		GeometryReader { geometry in
			VStack(alignment: .leading) {
				ZStack(alignment: .topTrailing) {
					self.firstMapFactory.mapView
					.frame(height: geometry.size.height / 2)
					Circle()
					.fill(self.viewModel.firstMapLoaded ? Color.green : Color.red)
					.frame(width: 20, height: 20)
					.padding()
				}
				Spacer()
				ZStack(alignment: .topTrailing) {
					self.secondMapFactory.mapView
					.frame(height: geometry.size.height / 2)
					Circle()
					.fill(self.viewModel.secondMapLoaded ? Color.green : Color.red)
					.frame(width: 20, height: 20)
					.padding()
				}
			}
		}
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: self.backButton, trailing: self.makeToggleView().padding())
	}

	private func makeToggleView() -> some View {
		Toggle(self.viewModel.useMultiViewPorts ? "On": "Off", isOn: self.$viewModel.useMultiViewPorts)
	}

	private var backButton: some View {
		Button(
			action: {
				self.presentationMode.wrappedValue.dismiss()
			}) {
			HStack {
				Image(systemName: "chevron.backward")
				Text("Back")
			}
		}
	}
}
