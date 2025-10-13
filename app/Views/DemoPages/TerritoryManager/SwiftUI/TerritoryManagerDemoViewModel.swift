import Combine
import DGis
import Foundation

final class TerritoryManagerDemoViewModel: ObservableObject, @unchecked Sendable {
	private enum Constants {
		static let searchDelay: TimeInterval = 0.3
		static let territoriesUpdateDelay: TimeInterval = 1
	}

	@Published private(set) var packages: [TerritoryViewModel] = []
	@Published private(set) var currentLocationTerritories: [TerritoryViewModel] = []
	@Published private(set) var viewportTerritories: [TerritoryViewModel] = []
	@Published var searchString: String = ""
	@Published var showDetailsSettings: Bool = false

	let territoryManagerSettingsViewModel: TerritoryManagerSettingsViewModel

	private var loadedPackages: [TerritoryViewModel] = []
	private let territoryManager: TerritoryManager
	private let map: Map
	private let mapSourceFactory: IMapSourceFactory
	private let locationService: DGis.LocationService

	private var territoriesCancellable: ICancellable?
	private var lastLocationCancellable: ICancellable?
	private var viewportCancellable: ICancellable?
	private var searchStringCancellable: AnyCancellable?
	private var territoryStatusSubscriptions = Set<AnyCancellable>()

	private let lastLocationSubject = PassthroughSubject<GeoPoint, Never>()
	private let visibleRectSubject = PassthroughSubject<GeoRect, Never>()
	private var lastLocationDebounceCancellable: AnyCancellable?
	private var viewportDebounceCancellable: AnyCancellable?

	init(
		territoryManager: TerritoryManager,
		mapSourceFactory: IMapSourceFactory,
		map: Map,
		locationService: DGis.LocationService,
		logger: ILogger
	) {
		self.territoryManagerSettingsViewModel = TerritoryManagerSettingsViewModel(logger: logger)
		self.territoryManager = territoryManager
		self.map = map
		self.mapSourceFactory = mapSourceFactory
		self.locationService = locationService

		self.map.addSource(
			source: mapSourceFactory.makeMyLocationMapObjectSource(
				bearingSource: .magnetic
			)
		)

		self.lastLocationDebounceCancellable = self.lastLocationSubject
			.debounce(for: .seconds(Constants.territoriesUpdateDelay), scheduler: DispatchQueue.main)
			.map { [territoryManager, territoryManagerSettingsViewModel = self.territoryManagerSettingsViewModel] point in
				territoryManager.findByPoint(geoPoint: point).map {
					TerritoryViewModel(
						package: $0,
						territoryManagerSettingsViewModel: territoryManagerSettingsViewModel
					)
				}
			}
			.sink { [weak self] territories in
				self?.currentLocationTerritories = territories
			}

		self.viewportDebounceCancellable = self.visibleRectSubject
			.debounce(for: .seconds(Constants.territoriesUpdateDelay), scheduler: DispatchQueue.main)
			.map { [territoryManager, territoryManagerSettingsViewModel = self.territoryManagerSettingsViewModel] rect in
				territoryManager.findByRect(rect: rect).map {
					TerritoryViewModel(
						package: $0,
						territoryManagerSettingsViewModel: territoryManagerSettingsViewModel
					)
				}
			}
			.sink { [weak self] territories in
				self?.viewportTerritories = territories
			}

		self.lastLocationCancellable = locationService.lastLocationChannel.sinkOnMainThread { lastLocation in
			guard let point = lastLocation?.coordinates.value else { return }
			self.lastLocationSubject.send(point)
		}

		self.viewportCancellable = map.camera.sinkOnStatefulChangesOnMainThread(reason: .visibleRect) {
			[weak self] (viewport: GeoRect) in
			guard let self else { return }
			self.visibleRectSubject.send(viewport)
		}

		self.territoriesCancellable = territoryManager.territoriesChannel.sinkOnMainThread {
			[weak self] _ in
			self?.updateTerritories()
		}
		self.searchStringCancellable = self.$searchString
			.debounce(for: .seconds(Constants.searchDelay), scheduler: DispatchQueue.main)
			.sink { [weak self] _ in
				self?.filterTerritories()
			}
		self.updateTerritories()
	}

	private func updateTerritories() {
		self.territoryStatusSubscriptions.removeAll()
		self.loadedPackages = self.territoryManager.territories.map {
			let viewModel = TerritoryViewModel(package: $0, territoryManagerSettingsViewModel: self.territoryManagerSettingsViewModel)
			viewModel.$status
				.dropFirst()
				.sink { [weak self] _ in
					self?.filterTerritories()
				}
				.store(in: &self.territoryStatusSubscriptions)
			return viewModel
		}
		self.filterTerritories()
	}

	private func filterTerritories() {
		if self.searchString.isEmpty {
			self.packages = self.sortLoadedTerritories()
		} else {
			self.packages = self.sortLoadedTerritories().filter { $0.title.localizedCaseInsensitiveContains(self.searchString) }
		}
	}

	private func sortLoadedTerritories() -> [TerritoryViewModel] {
		self.loadedPackages.sorted(by: {
			$0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
		})
	}
}
