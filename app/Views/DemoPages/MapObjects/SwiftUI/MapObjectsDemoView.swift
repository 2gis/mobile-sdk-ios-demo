import SwiftUI
import DGis

struct MapObjectsDemoView: View {
	@ObservedObject private var viewModel: MapObjectsDemoViewModel
	private let mapFactory: IMapFactory
	
	init(
		viewModel: MapObjectsDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack {
			ZStack(alignment: .bottomTrailing) {
				self.mapFactory.mapViewOverlay
					.mapViewOverlayShowsAPIVersion(true)
					.mapViewOverlayCopyrightAlignment(.bottomLeft)
					.mapViewOverlayObjectTappedCallback(callback: .init(
						callback: { [viewModel = self.viewModel] objectInfo in
							viewModel.tap(objectInfo: objectInfo)
						}
					))
				VStack(spacing: 12.0) {
					if !self.viewModel.showObjects {
						self.settingsButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
					}
					if self.viewModel.showObjects {
						switch self.viewModel.mapObjectType {
						case .circle:
							self.makeCircleView()
						case .marker:
							self.makeMarkerView()
						case .model:
							self.makeModelView()
						case .polygon:
							self.makePolygonView()
						case .polyline:
							self.makePolylineView()
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
					self.makeRenderedObjectInfoView(selectedMapObject)
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

	private func makeRenderedObjectInfoView(_ viewModel: RenderedObjectInfoViewModel) -> some View {
		return RenderedObjectInfoView(viewModel: viewModel)
	}

	private func makeCircleView() -> some View {
		return CircleView(
			viewModel: self.viewModel.circleViewModel,
			show: self.$viewModel.showObjects
		)
	}

	private func makeMarkerView() -> some View {
		return MarkerView(
			viewModel: self.viewModel.markerViewModel,
			show: self.$viewModel.showObjects
		)
	}

	private func makeModelView() -> some View {
		return ModelView(
			viewModel: self.viewModel.modelViewModel,
			show: self.$viewModel.showObjects
		)
	}

	private func makePolygonView() -> some View {
		return PolygonView(
			viewModel: self.viewModel.polygonViewModel,
			show: self.$viewModel.showObjects
		)
	}

	private func makePolylineView() -> some View {
		return PolylineView(
			viewModel: self.viewModel.polylineViewModel,
			show: self.$viewModel.showObjects
		)
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "pin.fill") {
			self.viewModel.showObjects = true
		}
	}
}
