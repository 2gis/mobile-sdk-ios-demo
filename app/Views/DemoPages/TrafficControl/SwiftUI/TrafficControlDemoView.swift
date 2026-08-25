import SwiftUI
import DGis

struct TrafficControlDemoView: View {
	@Environment(\.presentationMode) private var presentationMode

	private var viewModel: TrafficControlDemoViewModel
	private let mapFactory: IMapFactory

	init(
		viewModel: TrafficControlDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack {
			self.mapFactory.mapView
			.copyrightAlignment(.bottomLeft)
			ZStack(alignment: .top) {
				VStack(alignment: .trailing) {
					HStack {
						self.mapFactory.mapViewsFactory.makeTrafficView(colors: .default)
						.frame(width: 48, height: 102)
						.fixedSize()
						.padding(20)
					}
					HStack {
						Spacer()
						self.mapFactory.mapViewsFactory.makeZoomView()
						.frame(width: 48, height: 48)
						.fixedSize()
						.padding(20)
					}
				}
			}
		}
		.edgesIgnoringSafeArea(.all)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: self.backButton)
	}

	private var backButton : some View {
		Button(action: {
			self.viewModel.saveState()
			self.presentationMode.wrappedValue.dismiss()
		}) {
			HStack {
				Image(systemName: "arrow.left.circle")
				Text("Back")
			}
		}
	}
}
