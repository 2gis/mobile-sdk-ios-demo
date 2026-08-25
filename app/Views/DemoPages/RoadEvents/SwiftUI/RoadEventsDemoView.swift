import DGis
import SwiftUI

struct RoadEventsDemoView: View {
	typealias State = SwiftUI.State

	@ObservedObject private var viewModel: RoadEventsDemoViewModel

	@State private var visibleAreaEdgeInsets = EdgeInsets()

	private let mapFactory: IMapFactory
	private let mapViewsFactory: IMapViewsFactory
	private let roadEventViewFactory: IRoadEventViewFactory

	init(
		viewModel: RoadEventsDemoViewModel,
		mapFactory: IMapFactory,
		roadEventViewFactory: IRoadEventViewFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.mapViewsFactory = mapFactory.mapViewsFactory
		self.roadEventViewFactory = roadEventViewFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			self.mapFactory.mapView
				.showsAPIVersion(true)
				.objectTappedCallback(callback: .init(
					callback: { [weak viewModel = self.viewModel] objectInfo in
						viewModel?.tap(objectInfo: objectInfo)
					}
				))
				.edgesIgnoringSafeArea(.all)
			if self.viewModel.isRoadEventFormPresented {
				self.roadEventViewFactory.makeRoadEventCreatorView(
					map: self.mapFactory.map,
					visibleAreaEdgeInsets: self.$visibleAreaEdgeInsets
				)
				.onCreateRequest { [weak viewModel = self.viewModel] createRoadEventResult in
					viewModel?.handle(createRoadEventResult)
				}
				.onCancel { [weak viewModel = self.viewModel] in
					viewModel?.hideRoadEventForm()
				}
				.onChange(of: self.visibleAreaEdgeInsets, perform: { newInsets in
					let scale = UIScreen.main.nativeScale
					let padding = Padding(
						left: UInt32(newInsets.leading * scale),
						top: UInt32(newInsets.top * scale),
						right: UInt32(newInsets.trailing * scale),
						bottom: UInt32(newInsets.bottom * scale)
					)
					self.viewModel.map.camera.padding = padding
				})
			} else if let roadEvent = self.viewModel.selectedRoadEvent {
				self.roadEventViewFactory.makeRoadEventInfoView(roadEvent)
					.closeButtonCallback { [weak viewModel = self.viewModel] in
						viewModel?.hideRoadEvent()
					}
					.actionResultCallback { [weak viewModel = self.viewModel] roadEventActionResult in
						viewModel?.handle(roadEventActionResult)
					}
					.removeRoadEventActionResultCallback { roadEventRemoveResult in
						self.viewModel.handle(roadEventRemoveResult)
					}
					.setRoadEvent(roadEvent)
					.background(Color(UIColor(named: "colors/road_event_info_background")!))
					.edgesIgnoringSafeArea(.all)
			} else {
				HStack {
					Spacer()
					VStack {
						Spacer()
						self.mapViewsFactory.makeZoomView()
							.frame(width: 48, height: 102)
							.fixedSize()
							.padding(.bottom, 20)
						self.mapViewsFactory.makeCurrentLocationView()
							.frame(width: 48, height: 48)
							.fixedSize()
						self.mapViewsFactory.makeRoadEventCreatorButtonView { [weak viewModel = self.viewModel] in
							viewModel?.createRoadEvent()
						}
						.frame(width: 48, height: 48)
						.fixedSize()
						Spacer()
					}
					.padding(.trailing, 20)
				}
			}
		}
		.alert(isPresented: self.$viewModel.isAlertShowing) {
			Alert(title: Text(self.viewModel.alertMessage ?? ""))
		}
		.sheet(isPresented: self.$viewModel.isFiltersShown) {
			RoadEventsDisplayFilterView(
				isPresented: self.$viewModel.isFiltersShown,
				visibleEvents: self.$viewModel.visibleEvents
			)
		}
		.navigationBarHidden(self.viewModel.isRoadEventFormPresented)
		.navigationBarItems(
			trailing: Button(
				"Filters",
				action: {
					self.viewModel.editFilters()
				}
			)
		)
	}
}
