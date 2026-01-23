import DGis
import SwiftUI

struct RouteSearchNGDemoView: View {
	private enum Constants {
		static let controlsPadding: CGFloat = 8
		static let controlsWidth: CGFloat = 48
		static let ladscapeLeadingOffset: CGFloat = 360
	}

	let mapFactory: IMapFactory
	let routeEditorViewFactory: IRouteEditorViewFactory
	let trafficRouter: TrafficRouter
	@ObservedObject var viewModel: RouteSearchNGDemoViewModel
	@Environment(\.presentationMode) private var presentationMode
	@SwiftUI.State private var isTrafficRouterBriefInfo = false
	@SwiftUI.State private var sheetHeight: CGFloat = 0
	@SwiftUI.State private var safeAreaInsets: EdgeInsets = .init()
	@SwiftUI.State private var routeEditorViewPosition: RouteEditorView.SheetPosition?

	private var zoomView: AnyView
	private var trafficView: AnyView
	private var indoorView: AnyView
	private var compassView: AnyView
	private var currentLocationView: AnyView

	init(
		mapFactory: IMapFactory,
		routeEditorViewFactory: IRouteEditorViewFactory,
		trafficRouter: TrafficRouter,
		viewModel: RouteSearchNGDemoViewModel
	) {
		self.mapFactory = mapFactory
		self.routeEditorViewFactory = routeEditorViewFactory
		self.trafficRouter = trafficRouter
		self.viewModel = viewModel

		self.zoomView = mapFactory.mapViewsFactory.makeZoomView()
		self.trafficView = mapFactory.mapViewsFactory.makeTrafficView(colors: .default)
		self.indoorView = mapFactory.mapViewsFactory.makeIndoorView()
		self.compassView = mapFactory.mapViewsFactory.makeCompassView()
		self.currentLocationView = mapFactory.mapViewsFactory.makeCurrentLocationView()
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
						viewModel?.onTapObject(info: objectInfo)
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
			ViewThatFits {
				self.controlsFull
				self.controlsLess
				self.controlsCompact
				self.controlsMinimal
			}
			if self.viewModel.routePoints.count >= 2 {
				self.routeEditorViewFactory.makeRouteEditorView(
					routeEditor: self.viewModel.routeEditor,
					briefInfoProvider: self.isTrafficRouterBriefInfo ? self.routeEditorViewFactory.makeTrafficRouterBriefInfoProvider(trafficRouter: self.trafficRouter) : nil,
					startNavigationCallback: { _ in },
					closeCallback: { self.presentationMode.wrappedValue.dismiss() },
					editRoutePointsCallBack: {}
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
		.toolbar(.hidden, for: .navigationBar)
		.alert("Add route point?", isPresented: Binding(
			get: { self.viewModel.pendingLongPressObjectInfo != nil },
			set: { newValue in
				if !newValue {
					self.viewModel.pendingLongPressObjectInfo = nil
				}
			}
		)) {
			Button("No", role: .cancel) {
				self.viewModel.pendingLongPressObjectInfo = nil
			}
			Button("Yes") {
				if let objectInfo = self.viewModel.pendingLongPressObjectInfo {
					self.viewModel.onLongPressObject(info: objectInfo)
				}
				self.viewModel.pendingLongPressObjectInfo = nil
			}
		}
	}

	private var isLandscape: Bool {
		UIScreen.main.bounds.width > UIScreen.main.bounds.height
	}

	private var controlsFull: some View {
		VStack(alignment: .trailing) {
			self.trafficView
			Spacer(minLength: 0)
			HStack {
				self.indoorView
				Spacer()
				self.zoomView
			}
			Spacer(minLength: 0)
			self.compassView
			self.currentLocationView
		}
		.padding([.top, .trailing], Constants.controlsPadding)
		.padding(.bottom, self.isLandscape ? Constants.controlsPadding : max(self.sheetHeight - self.safeAreaInsets.bottom, 0))
		.padding(.leading, self.isLandscape ? 360 + Constants.controlsPadding : Constants.controlsPadding)
	}

	private var controlsLess: some View {
		HStack {
			Spacer()
			VStack(alignment: .trailing) {
				self.trafficView
				Spacer(minLength: 0)
				self.compassView
				self.currentLocationView
			}
		}
		.padding([.top, .trailing], Constants.controlsPadding)
		.padding(.bottom, self.isLandscape ? Constants.controlsPadding : self.sheetHeight - self.safeAreaInsets.bottom)
		.padding(.leading, self.isLandscape ? 360 + Constants.controlsPadding : Constants.controlsPadding)
	}

	private var controlsCompact: some View {
		HStack {
			Spacer()
			VStack(alignment: .trailing) {
				self.trafficView
				Spacer(minLength: 0)
				self.currentLocationView
			}
		}
		.padding([.top, .trailing], Constants.controlsPadding)
		.padding(.bottom, self.isLandscape ? Constants.controlsPadding : self.sheetHeight - self.safeAreaInsets.bottom)
		.padding(.leading, self.isLandscape ? 360 + Constants.controlsPadding : Constants.controlsPadding)
	}

	private var controlsMinimal: some View {
		HStack {
			Spacer()
			VStack(alignment: .trailing) {
				self.trafficView
					.padding([.top, .trailing], Constants.controlsPadding)
				Spacer(minLength: 0)
			}
		}
	}
}
