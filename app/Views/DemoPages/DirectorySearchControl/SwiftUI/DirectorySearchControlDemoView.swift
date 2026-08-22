import DGis
import SwiftUI

struct DirectorySearchControlDemoView: View {
	private let mapFactory: IMapFactory
	private let searchManager: SearchManager
	private let searchHistory: SearchHistory
	private let imageFactory: IImageFactory
	private let myLocationMapObjectSource: MyLocationMapObjectSource
	private let defaultDirectoryViewsFactory: IDirectoryViewsFactory
	private let customDirectoryViewsFactory: IDirectoryViewsFactory
	private let logger: ILogger
#if ROUTING_FEATURE_AVAILABLE
	private let trafficRouter: TrafficRouter
	private let locationService: DGis.LocationService
#endif

#if ROUTING_FEATURE_AVAILABLE
	init(
		mapFactory: IMapFactory,
		searchManager: SearchManager,
		searchHistory: SearchHistory,
		imageFactory: IImageFactory,
		myLocationMapObjectSource: MyLocationMapObjectSource,
		defaultDirectoryViewsFactory: IDirectoryViewsFactory,
		customDirectoryViewsFactory: IDirectoryViewsFactory,
		logger: ILogger,
		trafficRouter: TrafficRouter,
		locationService: DGis.LocationService
	) {
		self.mapFactory = mapFactory
		self.searchManager = searchManager
		self.searchHistory = searchHistory
		self.imageFactory = imageFactory
		self.myLocationMapObjectSource = myLocationMapObjectSource
		self.defaultDirectoryViewsFactory = defaultDirectoryViewsFactory
		self.customDirectoryViewsFactory = customDirectoryViewsFactory
		self.logger = logger
		self.trafficRouter = trafficRouter
		self.locationService = locationService
	}
#else
	init(
		mapFactory: IMapFactory,
		searchManager: SearchManager,
		searchHistory: SearchHistory,
		imageFactory: IImageFactory,
		myLocationMapObjectSource: MyLocationMapObjectSource,
		defaultDirectoryViewsFactory: IDirectoryViewsFactory,
		customDirectoryViewsFactory: IDirectoryViewsFactory,
		logger: ILogger
	) {
		self.mapFactory = mapFactory
		self.searchManager = searchManager
		self.searchHistory = searchHistory
		self.imageFactory = imageFactory
		self.myLocationMapObjectSource = myLocationMapObjectSource
		self.defaultDirectoryViewsFactory = defaultDirectoryViewsFactory
		self.customDirectoryViewsFactory = customDirectoryViewsFactory
		self.logger = logger
	}
#endif

	var body: some View {
#if ROUTING_FEATURE_AVAILABLE
		DirectorySearchResultsSettingsView(
			mapFactory: self.mapFactory,
			searchManager: self.searchManager,
			searchHistory: self.searchHistory,
			imageFactory: self.imageFactory,
			myLocationMapObjectSource: self.myLocationMapObjectSource,
			defaultDirectoryViewsFactory: self.defaultDirectoryViewsFactory,
			customDirectoryViewsFactory: self.customDirectoryViewsFactory,
			logger: self.logger,
			trafficRouter: self.trafficRouter,
			locationService: self.locationService
		)
#else
		DirectorySearchResultsSettingsView(
			mapFactory: self.mapFactory,
			searchManager: self.searchManager,
			searchHistory: self.searchHistory,
			imageFactory: self.imageFactory,
			myLocationMapObjectSource: self.myLocationMapObjectSource,
			defaultDirectoryViewsFactory: self.defaultDirectoryViewsFactory,
			customDirectoryViewsFactory: self.customDirectoryViewsFactory,
			logger: self.logger
		)
#endif
	}
}

@MainActor
struct DirectorySearchResultsContentView: View {
	typealias State = SwiftUI.State

	private let mapFactory: IMapFactory
	private let directoryViewsFactory: IDirectoryViewsFactory
	private let directorySearchView: DirectorySearchView
	@StateObject private var viewModel: DirectorySearchControlDemoViewModel
	@State private var mapViewsFactory: IMapViewsFactory?
	@Environment(\.presentationMode) private var presentationMode

#if ROUTING_FEATURE_AVAILABLE
	init(
		mapFactory: IMapFactory,
		searchManager: SearchManager,
		searchHistory: SearchHistory,
		directoryViewsFactory: IDirectoryViewsFactory,
		imageFactory: IImageFactory,
		myLocationMapObjectSource: MyLocationMapObjectSource,
		paginationMode: DirectorySearchPaginationMode,
		categorySource: DirectorySearchResultsDemoCategorySource,
		usesCustomCategoriesView: Bool,
		metricMode: DirectorySearchResultsDemoMetricMode,
		trafficRouter: TrafficRouter,
		locationService: DGis.LocationService,
		logger: ILogger
	) {
		self.mapFactory = mapFactory
		self.directoryViewsFactory = directoryViewsFactory
		let categoriesViewProvider: DirectorySearchCategoriesViewProvider? = usesCustomCategoriesView
			? Self.makeCustomCategoriesView(context:)
			: nil
		let viewModel = DirectorySearchControlDemoViewModel(
			mapFactory: mapFactory,
			searchManager: searchManager,
			searchHistory: searchHistory,
			imageFactory: imageFactory,
			myLocationMapObjectSource: myLocationMapObjectSource,
			paginationMode: paginationMode,
			categorySource: categorySource,
			categoriesViewProvider: categoriesViewProvider,
			metricMode: metricMode,
			trafficRouter: trafficRouter,
			locationService: locationService,
			logger: logger
		)
		self._viewModel = StateObject(wrappedValue: viewModel)
		self.directorySearchView = Self.makeDirectorySearchView(
			directoryViewsFactory: directoryViewsFactory,
			viewModel: viewModel
		)
	}
#else
	init(
		mapFactory: IMapFactory,
		searchManager: SearchManager,
		searchHistory: SearchHistory,
		directoryViewsFactory: IDirectoryViewsFactory,
		imageFactory: IImageFactory,
		myLocationMapObjectSource: MyLocationMapObjectSource,
		paginationMode: DirectorySearchPaginationMode,
		categorySource: DirectorySearchResultsDemoCategorySource,
		usesCustomCategoriesView: Bool,
		logger: ILogger
	) {
		self.mapFactory = mapFactory
		self.directoryViewsFactory = directoryViewsFactory
		let categoriesViewProvider: DirectorySearchCategoriesViewProvider? = usesCustomCategoriesView
			? Self.makeCustomCategoriesView(context:)
			: nil
		let viewModel = DirectorySearchControlDemoViewModel(
			mapFactory: mapFactory,
			searchManager: searchManager,
			searchHistory: searchHistory,
			imageFactory: imageFactory,
			myLocationMapObjectSource: myLocationMapObjectSource,
			paginationMode: paginationMode,
			categorySource: categorySource,
			categoriesViewProvider: categoriesViewProvider,
			logger: logger
		)
		self._viewModel = StateObject(wrappedValue: viewModel)
		self.directorySearchView = Self.makeDirectorySearchView(
			directoryViewsFactory: directoryViewsFactory,
			viewModel: viewModel
		)
	}
#endif

	var body: some View {
		ZStack {
			self.mapFactory.mapView
				.objectTappedCallback(callback: .init(
					callback: { [viewModel = self.viewModel] objectInfo in
						Task { @MainActor in
							viewModel.getMarkerItemInfo(objectInfo: objectInfo)
						}
					}
				))
				.showsAPIVersion(true)
				.copyrightAlignment(.bottomLeft)
				.ignoresSafeArea(.all)

			self.mapControls

			if self.viewModel.selectedObject == nil {
				self.directorySearchView
					.transition(.move(edge: .bottom))
					.ignoresSafeArea(.all, edges: .vertical)
			}

			if let selectedObject = self.viewModel.selectedObject {
				self.directoryViewsFactory.makeDirectoryObjectView(
					onDismiss: self.viewModel.dismissObjectCard,
					onShowEntrances: nil,
					visibleAreaEdgeInsets: self.$viewModel.objectVisibleAreaEdgeInsets
				)
				.directoryObject(selectedObject)
				.objectMetricSource(self.viewModel.objectMetricSource)
				.id("DirectorySearchSelectedObjectCard")
				.transition(.move(edge: .bottom))
				.ignoresSafeArea(.all, edges: .vertical)
			}
		}
		.animation(.easeInOut(duration: 0.35), value: self.viewModel.selectedObject != nil)
		.onAppear(perform: self.viewModel.onAppear)
		.task {
			guard self.mapViewsFactory == nil else { return }
			guard (try? await self.mapFactory.mapAsync) != nil else { return }
			self.mapViewsFactory = self.mapFactory.mapViewsFactory
		}
		.onDisappear(perform: self.viewModel.onDisappear)
		.toolbar(.hidden, for: .navigationBar)
	}

	private static func makeDirectorySearchView(
		directoryViewsFactory: IDirectoryViewsFactory,
		viewModel: DirectorySearchControlDemoViewModel
	) -> DirectorySearchView {
		directoryViewsFactory.makeDirectorySearchView(
			searchManager: viewModel.searchManager,
			searchHistory: viewModel.searchHistory,
			visibleAreaEdgeInsets: Binding(
				get: { viewModel.visibleAreaEdgeInsets },
				set: { viewModel.visibleAreaEdgeInsets = $0 }
			),
			expansionState: Binding(
				get: { viewModel.searchExpansionState },
				set: { viewModel.searchExpansionState = $0 }
			),
			configuration: viewModel.configuration,
			onObjectTap: viewModel.showObjectCard
		)
	}

	private var mapControls: some View {
		VStack {
			HStack {
				self.backButton
				Spacer()
			}
			Spacer()
			if let mapViewsFactory {
				HStack {
					Spacer()
					mapViewsFactory.makeZoomView()
				}
				Spacer()
				HStack {
					Spacer()
					mapViewsFactory.makeCurrentLocationView(permissionCallback: {})
				}
				.padding(.bottom, 80)
			}
		}
		.padding(12)
	}

	private var backButton: some View {
		Button(action: {
			self.presentationMode.wrappedValue.dismiss()
		}) {
			ZStack {
				Rectangle()
					.foregroundStyle(.background)
					.shadow(color: .black.opacity(0.04), radius: 4)
				SwiftUI.Image(systemName: "arrowtriangle.backward.fill")
					.foregroundStyle(.foreground)
					.frame(width: 24, height: 24)
			}
		}
		.buttonStyle(HighlightedButtonStyle(highlighted: .constant(false), applyOverlay: true))
		.frame(width: 44, height: 44)
		.clipShape(RoundedRectangle(cornerRadius: 10))
	}

	private static func makeCustomCategoriesView(context: DirectorySearchCategoriesViewContext) -> AnyView {
		AnyView(
			DirectorySearchCustomCategoriesPlaceholderView(context: context)
		)
	}
}

private struct DirectorySearchCustomCategoriesPlaceholderView: View {
	let context: DirectorySearchCategoriesViewContext

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Custom categories view")
				.font(.headline)

			switch self.context.loadState {
			case .loading:
				ProgressView()
			case .content:
				Text("Total: \(self.totalCategoriesText)")
					.font(.subheadline)
			case .empty:
				Text("No categories")
					.font(.subheadline)
			case let .error(message):
				Text(message)
					.font(.subheadline)
			@unknown default:
				EmptyView()
			}
		}
		.foregroundStyle(.primary)
		.frame(maxWidth: .infinity, alignment: .leading)
		.padding(16)
		.background(.thinMaterial)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.padding(.horizontal, 14)
	}

	private var totalCategoriesText: String {
		String.localizedStringWithFormat(
			self.context.localization.countFormat,
			Int(self.context.totalCount)
		)
	}
}
