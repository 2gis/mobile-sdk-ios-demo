import SwiftUI
import DGis

struct CacheDemoView: View {
	private enum Constants {
		static let settingsHeight: CGFloat = 120
		static let maxCacheSizeValue: Double = 1024*1024*1024
		static let cacheSizeStepValue: Double = 1024*1024
	}

	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject private var viewModel: CacheDemoViewModel
	private let mapFactory: IMapFactory

	init(
		viewModel: CacheDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}
	
	var body: some View {
		GeometryReader { geometry in
			ZStack(alignment: .bottomTrailing) {
				self.mapFactory.mapViewOverlay
				.mapViewOverlayShowsAPIVersion(true)
				.mapViewOverlayCopyrightAlignment(.bottomLeft)
				.mapViewOverlayCopyrightInsets(
					EdgeInsets(
						top: 0,
						leading: 0,
						bottom: Constants.settingsHeight - geometry.safeAreaInsets.bottom,
						trailing: 0
					)
				)
				self.makeCacheSettings(height: Constants.settingsHeight)
			}
			.edgesIgnoringSafeArea(.all)
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading: self.backButton, trailing: self.clearButton)
		}
	}

	private var backButton: some View {
		Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
			HStack {
				Image(systemName: "chevron.backward")
				Text("Back")
			}
		}
	}

	private var clearButton: some View {
		Button(action: { self.viewModel.clearCache() }) {
			ZStack {
				RoundedRectangle(cornerRadius: 8.0)
				.fill(Color(UIColor.systemBackground))
				Text("Clear cache")
				.foregroundColor(.accentColor)
				.padding(5)
			}
		}
		.buttonStyle(PlainButtonStyle())
	}

	private func makeCacheSettings(height: CGFloat) -> some View {
		Rectangle()
			.fill(Color(UIColor.systemBackground).opacity(0.5))
			.frame(height: height)
			.overlay(
				VStack(spacing: 10.0) {
					Text("Cache size: \(self.viewModel.combinedCacheSize)")
					.font(.caption)
					.foregroundColor(Color(UIColor.label))
					Slider(
						value: self.$viewModel.cacheSize,
						in: 0...Constants.maxCacheSizeValue,
						step: Constants.cacheSizeStepValue
					)
					Spacer()
				}
				.padding()
			)
	}
}
