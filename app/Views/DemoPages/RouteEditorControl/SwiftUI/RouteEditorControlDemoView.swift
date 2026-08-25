import DGis
import SwiftUI

struct RouteEditorControlDemoView: View {
	private enum Constants {
		static let controlsPadding: CGFloat = 8
		static let controlsWidth: CGFloat = 48
		static let ladscapeLeadingOffset: CGFloat = 360
	}

	let mapFactory: IMapFactory
	let routeEditorViewFactory: IRouteEditorViewFactory
	let trafficRouter: TrafficRouter
	@ObservedObject var viewModel: RouteEditorControlDemoViewModel
	@Environment(\.presentationMode) private var presentationMode
	@SwiftUI.State private var isTrafficRouterBriefInfo = false
	@SwiftUI.State private var sheetHeight: CGFloat = 0
	@SwiftUI.State private var safeAreaInsets: EdgeInsets = .init()
	@SwiftUI.State private var routeEditorViewPosition: RouteEditorView.SheetPosition?
	@SwiftUI.State private var showStartNavigationStub = false
	@SwiftUI.State private var showEditRouteStub = false
	@SwiftUI.State private var mapViewsFactory: IMapViewsFactory?

	init(
		mapFactory: IMapFactory,
		routeEditorViewFactory: IRouteEditorViewFactory,
		trafficRouter: TrafficRouter,
		viewModel: RouteEditorControlDemoViewModel
	) {
		self.mapFactory = mapFactory
		self.routeEditorViewFactory = routeEditorViewFactory
		self.trafficRouter = trafficRouter
		self.viewModel = viewModel
	}

	var body: some View {
		ZStack(alignment: .bottom) {
			self.mapFactory.mapView
				.copyrightAlignment(.bottomLeft)
				.copyrightInsets(.init(
					top: 0,
					leading: self.isLandscape ? Constants.ladscapeLeadingOffset : 0,
					bottom: self.isLandscape ? 0 : max(self.sheetHeight - self.safeAreaInsets.bottom, 0),
					trailing: 0
				))
				.objectTappedCallback(callback: .init(
					callback: { [weak viewModel = self.viewModel] objectInfo in
						Task { @MainActor in
							viewModel?.onTapObject(info: objectInfo)
						}
					}
				))
				.objectLongPressCallback(callback: .init(
					callback: { [weak viewModel = self.viewModel] objectInfo in
						Task { @MainActor in
							viewModel?.pendingLongPressObjectInfo = objectInfo
						}
					}
				))
				.ignoresSafeArea(.all)
			if let mapViewsFactory {
				ViewThatFits {
					self.controlsFull(mapViewsFactory: mapViewsFactory)
					self.controlsLess(mapViewsFactory: mapViewsFactory)
					self.controlsCompact(mapViewsFactory: mapViewsFactory)
					self.controlsMinimal(mapViewsFactory: mapViewsFactory)
				}
			}
			if self.viewModel.routePoints.count >= 2 {
				self.routeEditorViewFactory.makeRouteEditorView(
					routeEditor: self.viewModel.routeEditor,
					briefInfoProvider: self.isTrafficRouterBriefInfo ? self.routeEditorViewFactory.makeTrafficRouterBriefInfoProvider(trafficRouter: self.trafficRouter) : nil,
					startNavigationCallback: { _ in
						self.showStartNavigationStub = true
					},
					closeCallback: { self.presentationMode.wrappedValue.dismiss() },
					editRoutePointsCallBack: {
						self.showEditRouteStub = true
					}
				)
				.routePoints(points: self.viewModel.routePoints)
				.sheetHeightChangeCallback { [weak viewModel = self.viewModel] position, height in
					self.sheetHeight = height
					viewModel?.applyCameraPaddings(
						insets: EdgeInsets(
							top: self.safeAreaInsets.top + Constants.controlsPadding,
							leading: self.isLandscape
								? self.safeAreaInsets.leading + Constants.ladscapeLeadingOffset + Constants.controlsPadding
								: self.safeAreaInsets.leading + Constants.controlsPadding,
							bottom: self.isLandscape
								? Constants.controlsPadding + self.safeAreaInsets.bottom
								: self.sheetHeight + Constants.controlsPadding,
							trailing: Constants.controlsPadding + Constants.controlsWidth + self.safeAreaInsets.trailing
						),
						scale: UIScreen.main.scale
					)
					guard position != self.routeEditorViewPosition else { return }
					self.routeEditorViewPosition = position
					guard self.routeEditorViewPosition != .maximized else { return }
					viewModel?.calcCameraPositionForRoutes()
				}
			}
		}
		.onGeometryChange(for: EdgeInsets.self) { proxy in
			proxy.safeAreaInsets
		} action: { insets in
			self.safeAreaInsets = insets
		}
		.onAppear {
			Task { @MainActor in
				guard (try? await self.mapFactory.mapAsync) != nil else { return }
				self.mapViewsFactory = self.mapFactory.mapViewsFactory
			}
		}
		.toolbar(.hidden, for: .navigationBar)
		.confirmationDialog("Add route point?", isPresented: Binding(
			get: { self.viewModel.pendingLongPressObjectInfo != nil },
			set: { newValue in
				if !newValue {
					self.viewModel.pendingLongPressObjectInfo = nil
				}
			}
		)) {
			Button("Route to") {
				if let objectInfo = self.viewModel.pendingLongPressObjectInfo {
					self.viewModel.onLongPressObject(info: objectInfo, type: .pointB)
				}
				self.viewModel.pendingLongPressObjectInfo = nil
			}
			if self.viewModel.routePoints.count >= 2 {
				Button("Intermidiate point") {
					if let objectInfo = self.viewModel.pendingLongPressObjectInfo {
						self.viewModel.onLongPressObject(info: objectInfo, type: .intermediate)
					}
					self.viewModel.pendingLongPressObjectInfo = nil
				}
			}
			Button("Route from") {
				if let objectInfo = self.viewModel.pendingLongPressObjectInfo {
					self.viewModel.onLongPressObject(info: objectInfo, type: .pointA)
				}
				self.viewModel.pendingLongPressObjectInfo = nil
			}
			Button("Cancel", role: .cancel) {
				self.viewModel.pendingLongPressObjectInfo = nil
			}
		}
		.alert("Start navigation", isPresented: self.$showStartNavigationStub) {
			Button("OK", role: .cancel) {}
		}
		.alert("Edit route", isPresented: self.$showEditRouteStub) {
			Button("OK", role: .cancel) {}
		}
	}

	private var isLandscape: Bool {
		UIScreen.main.bounds.width > UIScreen.main.bounds.height
	}

	private func controlsFull(mapViewsFactory: IMapViewsFactory) -> some View {
		VStack(alignment: .trailing) {
			mapViewsFactory.makeTrafficView()
			Spacer(minLength: 0)
			HStack {
				mapViewsFactory.makeIndoorView(showOverview: false)
				Spacer()
				mapViewsFactory.makeZoomView()
			}
			Spacer(minLength: 0)
			mapViewsFactory.makeCompassView()
			mapViewsFactory.makeCurrentLocationView(permissionCallback: {})
		}
		.padding([.top, .trailing], Constants.controlsPadding)
		.padding(.bottom, self.isLandscape ? Constants.controlsPadding : max(self.sheetHeight - self.safeAreaInsets.bottom, 0))
		.padding(.leading, self.isLandscape ? 360 + Constants.controlsPadding : Constants.controlsPadding)
	}

	private func controlsLess(mapViewsFactory: IMapViewsFactory) -> some View {
		HStack {
			Spacer()
			VStack(alignment: .trailing) {
				mapViewsFactory.makeTrafficView()
				Spacer(minLength: 0)
				mapViewsFactory.makeCompassView()
				mapViewsFactory.makeCurrentLocationView(permissionCallback: {})
			}
		}
		.padding([.top, .trailing], Constants.controlsPadding)
		.padding(.bottom, self.isLandscape ? Constants.controlsPadding : self.sheetHeight - self.safeAreaInsets.bottom)
		.padding(.leading, self.isLandscape ? 360 + Constants.controlsPadding : Constants.controlsPadding)
	}

	private func controlsCompact(mapViewsFactory: IMapViewsFactory) -> some View {
		HStack {
			Spacer()
			VStack(alignment: .trailing) {
				mapViewsFactory.makeTrafficView()
				Spacer(minLength: 0)
				mapViewsFactory.makeCurrentLocationView(permissionCallback: {})
			}
		}
		.padding([.top, .trailing], Constants.controlsPadding)
		.padding(.bottom, self.isLandscape ? Constants.controlsPadding : self.sheetHeight - self.safeAreaInsets.bottom)
		.padding(.leading, self.isLandscape ? 360 + Constants.controlsPadding : Constants.controlsPadding)
	}

	private func controlsMinimal(mapViewsFactory: IMapViewsFactory) -> some View {
		HStack {
			Spacer()
			VStack(alignment: .trailing) {
				mapViewsFactory.makeTrafficView()
					.padding([.top, .trailing], Constants.controlsPadding)
				Spacer(minLength: 0)
			}
		}
	}
}
