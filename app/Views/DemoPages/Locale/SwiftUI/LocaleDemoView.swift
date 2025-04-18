import SwiftUI
import DGis

struct LocaleDemoView: View {
	@ObservedObject private var viewModel: LocaleDemoViewModel
	private let mapFactory: IMapFactory
	
	init(
		viewModel: LocaleDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}
	
	var body: some View {
		ZStack {
			ZStack(alignment: .bottomTrailing) {
				self.mapFactory.mapViewOverlay
				.mapViewOverlayCopyrightAlignment(.bottomLeft)
				VStack(spacing: 12.0) {
					DetailsActionView(
						action: {
							self.viewModel.switchToNextLocale()
						},
						primaryText: self.viewModel.currentLocales,
						detailsText: "Language switcher"
					)
					VStack {
						Text("System locales")
						.font(.caption)
						.foregroundColor(.gray)
						Text(self.viewModel.systemLocales)
						.font(.system(size: 18, weight: .regular))
						.foregroundColor(.black)
					}
					.background(
						RoundedRectangle(cornerRadius: 6)
						.scale(1.2)
						.fill(Color.white)
					)
				}
				.padding(.trailing, 40.0)
				.padding(.bottom, 60.0)
			}
			.edgesIgnoringSafeArea(.all)
		}
	}
}
