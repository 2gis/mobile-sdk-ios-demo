import SwiftUI

struct MarkersDemoView: View {
	@State private var keyboardOffset: CGFloat = 0
	@ObservedObject private var viewModel: MarkersDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: MarkersDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}
	var body: some View {
		ZStack {
			ZStack(alignment: .bottomTrailing) {
				self.viewFactory.makeMapViewWithZoomControl(alignment: .bottomLeft) { location in
					self.viewModel.tap(location)
				}
				if !self.viewModel.showMarkers {
					self.settingsButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
				}
				if self.viewModel.showMarkers {
					self.viewFactory
					.makeMarkerView(viewModel: self.viewModel.markerViewModel, show: $viewModel.showMarkers)
					.followKeyboard($keyboardOffset)
				}
				if let cardViewModel = self.viewModel.selectedObjectCardViewModel {
					self.viewFactory
					.makeMapObjectCardView(cardViewModel)
					.transition(.move(edge: .bottom))
				}
			}
			if self.viewModel.showMarkers {
				Image(systemName: "multiply")
				.frame(width: 40, height: 40, alignment: .center)
				.foregroundColor(.red).opacity(0.4)
			}
		}
		.edgesIgnoringSafeArea(.all)
	}

	private func settingsButton() -> some View {
		Button(action: {
			self.viewModel.showMarkers = true
		}, label: {
			Image(systemName: "pin.fill")
			.frame(width: 40, height: 40, alignment: .center)
			.contentShape(Rectangle())
			.background(
				Circle().fill(Color.white)
			)
		})
		.padding(.bottom, 40)
		.padding(.trailing, 20)
	}
}
