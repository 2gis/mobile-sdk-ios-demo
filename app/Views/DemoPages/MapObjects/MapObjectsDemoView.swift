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
				self.viewFactory.makeMapViewWithZoomControl(alignment: .bottomLeft) { [viewModel = self.viewModel] objectInfo in
					viewModel.tap(objectInfo: objectInfo)
				}
				VStack(spacing: 12.0) {
					if !self.viewModel.showObjects {
						self.settingsButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
					}
					if self.viewModel.showObjects {
						switch self.viewModel.mapObjectType {
						case .circle:
							self.viewFactory.makeCircleView(
								viewModel: self.viewModel.circleViewModel,
								show: self.$viewModel.showObjects
							)
						case .marker:
							self.viewFactory.makeMarkerView(
								viewModel: self.viewModel.markerViewModel,
								show: self.$viewModel.showObjects
							)
						case .model:
							self.viewFactory.makeModelView(
								viewModel: self.viewModel.modelViewModel,
								show: self.$viewModel.showObjects
							)
						case .polygon:
							self.viewFactory.makePolygonView(
								viewModel: self.viewModel.polygonViewModel,
								show: self.$viewModel.showObjects
							)
						case .polyline:
							self.viewFactory.makePolylineView(
								viewModel: self.viewModel.polylineViewModel,
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

				if let selectedMapObject = self.viewModel.selectedMapObject {
					self.viewFactory.makeRenderedObjectInfoView(selectedMapObject)
						.transition(.move(edge: .bottom))
				}
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
