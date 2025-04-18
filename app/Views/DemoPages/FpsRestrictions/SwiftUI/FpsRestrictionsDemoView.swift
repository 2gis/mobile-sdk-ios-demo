import SwiftUI
import DGis

struct FpsRestrictionsDemoView: View {
	private enum Constants {
		static let settingsHeight: CGFloat = 150
	}
	
	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject private var viewModel: FpsRestrictionsDemoViewModel
	private let mapFactory: IMapFactory

	init(
		viewModel: FpsRestrictionsDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .bottom) {
				self.mapFactory.mapViewOverlay
				.mapViewOverlayShowsAPIVersion(true)
				.mapViewOverlayCopyrightAlignment(.bottomRight)
				.mapViewOverlayCopyrightInsets(
					EdgeInsets(
						top: 0,
						leading: 0,
						bottom: Constants.settingsHeight,
						trailing: 0
					)
				)
				self.makeFpsSettings(height: Constants.settingsHeight + geometry.safeAreaInsets.bottom)
			}
			.edgesIgnoringSafeArea(.all)
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading: self.backButton, trailing: self.fpsButton)
		}
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

	private var fpsButton: some View {
		Button(action: {
			self.viewModel.startCameraMoving()
		}) {
			Text(String(format: "%.4f", self.viewModel.currentFps))
			.bold()
			.foregroundColor(Color(UIColor.label))
		}
	}
	
	private func makeFpsSettings(height: CGFloat) -> some View {
		Rectangle()
		.fill(Color(UIColor.systemBackground).opacity(0.5))
		.frame(height: height)
		.overlay(
			VStack(alignment: .leading, spacing: 20){
				VStack(spacing: 8.0) {
					Text("Maximum FPS: \(String(format: "%.0f", self.viewModel.maxFps))")
						.font(.caption)
						.foregroundColor(Color(UIColor.label))
					Slider(
						value: self.$viewModel.maxFps,
						in: 1...self.viewModel.maxRefreshRate,
						step: 1
					)
					.accentColor(.green)
				}
				.padding(.horizontal, 20)
				VStack(spacing: 8.0) {
					Text("Max FPS for Low Power Mode: \(String(format: "%.0f", self.viewModel.powerSavingMaxFps))")
						.font(.caption)
						.foregroundColor(Color(UIColor.label))
					Slider(
						value: self.$viewModel.powerSavingMaxFps,
						in: 1...self.viewModel.maxRefreshRate,
						step: 1
					)
					.accentColor(.yellow)
				}
				.padding(.horizontal, 20)
			}
			.padding()
		)
	}
}
