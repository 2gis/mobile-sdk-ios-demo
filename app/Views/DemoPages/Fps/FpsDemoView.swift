import SwiftUI

struct FpsDemoView: View {
	@State private var keyboardOffset: CGFloat = 0
	@ObservedObject private var viewModel: FpsDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: FpsDemoViewModel,
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
						Text("Current FPS: \(self.viewModel.currentFps)")
						.font(.caption)
						.foregroundColor(.gray)
					}
					.background(
						RoundedRectangle(cornerRadius: 6)
						.scale(1.2)
						.fill(Color.white)
					)
					VStack {
						Text("Max fps")
						.font(.caption)
						.foregroundColor(.gray)
						TextField("", text: self.$viewModel.maxFps)
						.multilineTextAlignment(.center)
						.frame(width: 50, height: 20, alignment: .center)
						.keyboardType(.numberPad)
					}
					.background(
						RoundedRectangle(cornerRadius: 6)
						.scale(1.2)
						.fill(Color.white)
					)
					VStack {
						Text("Max fps in power saving mode")
						.font(.caption)
						.foregroundColor(.gray)
						TextField("", text: self.$viewModel.powerSavingMaxFps)
						.multilineTextAlignment(.center)
						.frame(width: 50, height: 20, alignment: .center)
						.keyboardType(.numberPad)
					}
					.background(
						RoundedRectangle(cornerRadius: 6)
						.scale(1.2)
						.fill(Color.white)
					)
					DetailsActionView(action: {
						self.viewModel.setFps()
					}, primaryText: "Set fps")
					DetailsActionView(action: {
						self.viewModel.startCameraMoving()
					}, primaryText: "Move camera around Moscow")
					if self.keyboardOffset > 0 {
						DetailsActionView(action: {
							UIApplication.shared.sendAction(
								#selector(UIResponder.resignFirstResponder),
								to: nil,
								from: nil,
								for: nil
							)
						}, primaryText: "OK")
					}
				}
				.padding(.trailing, 40.0)
				.padding(.bottom, 60.0)
				.followKeyboard($keyboardOffset)
			}
		}
		.edgesIgnoringSafeArea(.all)
	}
}
