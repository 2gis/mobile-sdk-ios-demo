import SwiftUI

struct MapObjectsDemoView: View {
	@ObservedObject private var viewModel: MapObjectsDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: MapObjectsDemoViewModel,
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
					if !self.viewModel.showObjects {
						self.settingsButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
					}
					if self.viewModel.showObjects {
						switch self.viewModel.mapObjectType {
							case .circle:
								self.viewFactory.makeCircleView(
									viewModel: self.viewModel.makeCircleViewModel(),
									show: self.$viewModel.showObjects
								)
							case .marker:
								self.viewFactory.makeMarkerView(
									viewModel: self.viewModel.makeMarkerViewModel(),
									show: self.$viewModel.showObjects
								)
							case .polygon:
								self.viewFactory.makePolygonView(
									viewModel: self.viewModel.makePolygonViewModel(),
									show: self.$viewModel.showObjects
								)
							case .polyline:
								self.viewFactory.makePolylineView(
									viewModel: self.viewModel.makePolylineViewModel(),
									show: self.$viewModel.showObjects
								)
						}
					}
					DetailsActionView(
						action: {
							self.viewModel.mapObjectType.next()
						},
						primaryText: self.viewModel.mapObjectType.text,
						detailsText: "Choose object type"
					)
					DetailsActionView(
						action: {
							self.viewModel.removeAll()
						},
						primaryText: "Remove all"
					)
				}
				.padding(.bottom, 40)
				.padding(.trailing, 20)
			}
			if self.viewModel.showObjects {
				Image(systemName: "multiply")
				.font(Font.system(size: 20, weight: .bold))
				.foregroundColor(.red)
				.shadow(radius: 3, x: 1, y: 1)
			}
		}
		.edgesIgnoringSafeArea(.all)
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "pin.fill") {
			self.viewModel.showObjects = true
		}
	}
}
