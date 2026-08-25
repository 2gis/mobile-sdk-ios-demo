import DGis
import SwiftUI

enum DirectorySearchResultsDemoThemeMode: String, CaseIterable, Hashable, Identifiable {
	case defaultTheme = "Default"
	case custom = "Custom"

	var id: Self {
		self
	}
}

enum DirectorySearchResultsDemoCategorySource: String, CaseIterable, Hashable, Identifiable {
	case currentPosition = "Current position"
	case visibleRect = "Visible rect"

	var id: Self {
		self
	}
}

#if ROUTING_FEATURE_AVAILABLE
enum DirectorySearchResultsDemoMetricMode: String, CaseIterable, Hashable, Identifiable {
	case distance = "Distance"
	case drivingTime = "Driving time"

	var id: Self {
		self
	}
}
#endif

struct DirectorySearchResultsSettingsView: View {
	typealias State = SwiftUI.State
	@EnvironmentObject private var navigationService: NavigationService

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

	@State private var selectedThemeMode: DirectorySearchResultsDemoThemeMode = .defaultTheme
	@State private var selectedPaginationMode: DirectorySearchPaginationMode = .automatic
	@State private var selectedCategorySource: DirectorySearchResultsDemoCategorySource = .currentPosition
	@State private var usesCustomCategoriesView = false
#if ROUTING_FEATURE_AVAILABLE
	@State private var selectedMetricMode: DirectorySearchResultsDemoMetricMode = .distance
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
		Form {
			Section(header: Text("Theme")) {
				Picker("Search results theme", selection: self.$selectedThemeMode) {
					ForEach(DirectorySearchResultsDemoThemeMode.allCases) { mode in
						Text(mode.rawValue).tag(mode)
					}
				}
				.pickerStyle(SegmentedPickerStyle())
			}

			Section(header: Text("Pagination")) {
				Picker("Pagination mode", selection: self.$selectedPaginationMode) {
					ForEach(DirectorySearchPaginationMode.allCases) { mode in
						Text(mode.demoTitle).tag(mode)
					}
				}
				.pickerStyle(SegmentedPickerStyle())
			}

			Section(header: Text("Categories")) {
				Picker("Category source", selection: self.$selectedCategorySource) {
					ForEach(DirectorySearchResultsDemoCategorySource.allCases) { source in
						Text(source.rawValue).tag(source)
					}
				}
				.pickerStyle(SegmentedPickerStyle())

				Toggle("Custom categories view", isOn: self.$usesCustomCategoriesView)
			}

#if ROUTING_FEATURE_AVAILABLE
			Section(header: Text("Metric")) {
				Picker("Object metric", selection: self.$selectedMetricMode) {
					ForEach(DirectorySearchResultsDemoMetricMode.allCases) { mode in
						Text(mode.rawValue).tag(mode)
					}
				}
				.pickerStyle(SegmentedPickerStyle())
			}
#endif

			Section {
				Button("Apply") {
					self.openConfiguredExample()
				}
				.frame(maxWidth: .infinity)
			}
		}
		.toolbar(.visible, for: .navigationBar)
		.navigationTitle("Search Results")
	}

	private func openConfiguredExample() {
		let directoryViewsFactory = self.selectedThemeMode == .defaultTheme
			? self.defaultDirectoryViewsFactory
			: self.customDirectoryViewsFactory
#if ROUTING_FEATURE_AVAILABLE
		self.navigationService.push(
			DirectorySearchResultsContentView(
				mapFactory: self.mapFactory,
				searchManager: self.searchManager,
				searchHistory: self.searchHistory,
				directoryViewsFactory: directoryViewsFactory,
				imageFactory: self.imageFactory,
				myLocationMapObjectSource: self.myLocationMapObjectSource,
				paginationMode: self.selectedPaginationMode,
				categorySource: self.selectedCategorySource,
				usesCustomCategoriesView: self.usesCustomCategoriesView,
				metricMode: self.selectedMetricMode,
				trafficRouter: self.trafficRouter,
				locationService: self.locationService,
				logger: self.logger
			)
			.navigationTitle("Search Results")
			.environmentObject(self.navigationService)
		)
#else
		self.navigationService.push(
			DirectorySearchResultsContentView(
				mapFactory: self.mapFactory,
				searchManager: self.searchManager,
				searchHistory: self.searchHistory,
				directoryViewsFactory: directoryViewsFactory,
				imageFactory: self.imageFactory,
				myLocationMapObjectSource: self.myLocationMapObjectSource,
				paginationMode: self.selectedPaginationMode,
				categorySource: self.selectedCategorySource,
				usesCustomCategoriesView: self.usesCustomCategoriesView,
				logger: self.logger
			)
			.navigationTitle("Search Results")
			.environmentObject(self.navigationService)
		)
#endif
	}
}

extension DirectorySearchPaginationMode {
	var demoTitle: String {
		switch self {
		case .automatic:
			"Auto"
		case .manual:
			"Manual"
		@unknown default:
			"Unknown"
		}
	}
}

extension DirectoryViewTheme {
	static var demoSearchResultsDefault: DirectoryViewTheme {
		.default
	}

	static var demoSearchResultsCustom: DirectoryViewTheme {
		DirectoryViewTheme(
			colors: DirectoryViewTheme.Colors(
				background: SwiftUI.Color(red: 1.00, green: 1.00, blue: 1.00),
				secondaryBackground: SwiftUI.Color(red: 0.94, green: 0.97, blue: 0.95),
				tertiaryBackground: SwiftUI.Color(red: 0.86, green: 0.93, blue: 0.88),
				primaryContent: SwiftUI.Color(red: 0.05, green: 0.11, blue: 0.08),
				secondaryContent: SwiftUI.Color(red: 0.38, green: 0.48, blue: 0.42),
				tertiaryContent: SwiftUI.Color(red: 0.76, green: 0.82, blue: 0.78),
				quaternaryContent: SwiftUI.Color(red: 0.60, green: 0.68, blue: 0.63),
				separator: SwiftUI.Color(red: 0.60, green: 0.9, blue: 0.2),
				alertGreen: SwiftUI.Color(red: 0.10, green: 0.63, blue: 0.21),
				alertYellow: SwiftUI.Color(red: 0.94, green: 0.66, blue: 0.00),
				alertRed: SwiftUI.Color(red: 0.86, green: 0.18, blue: 0.17),
				selectedDynamicFilterContent: SwiftUI.Color(red: 0.05, green: 0.11, blue: 0.08),
				selectedDynamicFilterBackground: SwiftUI.Color(red: 0.94, green: 0.97, blue: 0.95),
				dynamicFilterIcon: SwiftUI.Color(red: 0.94, green: 0.97, blue: 0.45),
				selectedDynamicFilterIcon: SwiftUI.Color(red: 0.05, green: 0.56, blue: 0.08),
				rangeFilterButtonText: SwiftUI.Color(red: 0.05, green: 0.11, blue: 0.08),
				rangeFilterSheetBackground: SwiftUI.Color(red: 0.94, green: 0.97, blue: 0.95),
				rangeFilterSliderBackground: SwiftUI.Color(red: 0.86, green: 0.93, blue: 0.88),
				rangeFilterSliderSelectedRange: SwiftUI.Color(red: 0.05, green: 0.11, blue: 0.08),
				rangeFilterSliderExcludedRange: SwiftUI.Color(red: 0.86, green: 0.18, blue: 0.17)
			),
			fonts: .default
		)
	}
}
