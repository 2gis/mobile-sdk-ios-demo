import Foundation
import Combine
import DGis

final class PackageManagerDemoViewModel: ObservableObject {
	private enum Constants {
		static let searchDelay: TimeInterval = 0.3
	}
	@Published private(set) var packages: [PackageViewModel] = []
	@Published var searchString: String = ""
	private var loadedPackages: [PackageViewModel] = []
	private let packageManager: PackageManager
	private let territoryManager: TerritoryManager
	private let roadMacroGraph: RoadMacroGraph
	private let map: Map

	private var territoriesCancellable: ICancellable?
	private var searchStringCancellable: AnyCancellable?
	private var territoryStatusSubscriptions = Set<AnyCancellable>()

	init(
		packageManager: PackageManager,
		territoryManager: TerritoryManager,
		roadMacroGraph: RoadMacroGraph,
		map: Map
	) {
		self.packageManager = packageManager
		self.territoryManager = territoryManager
		self.map = map
		self.roadMacroGraph = roadMacroGraph

		self.territoriesCancellable = territoryManager.territoriesChannel.sinkOnMainThread({
			[weak self] _ in
			self?.updateTerritories()
		})
		self.searchStringCancellable = self.$searchString
			.debounce(for: .seconds(Constants.searchDelay), scheduler: DispatchQueue.main)
			.sink { [weak self] output in
				self?.filterTerritories()
			}
		self.updateTerritories()
		self.checkForUpdates()
	}

	func checkForUpdates() {
		self.packageManager.checkForUpdates()
	}

	private func updateTerritories() {
		self.territoryStatusSubscriptions.removeAll()
		self.loadedPackages = self.territoryManager.territories.map {
			let viewModel = PackageViewModel(package: $0)
			viewModel.$status
				.dropFirst()
				.filter { $0 == .installed || $0 == .notInstalled }
				.sink { [weak self] _ in
					self?.filterTerritories()
				}
				.store(in: &self.territoryStatusSubscriptions)
			return viewModel
		}
		self.loadedPackages.append(PackageViewModel(package: roadMacroGraph))
		self.filterTerritories()
	}

	private func filterTerritories() {
		if self.searchString.isEmpty {
			self.packages = self.sortLoadedTerritories()
		} else {
			self.packages = self.sortLoadedTerritories().filter { $0.name.localizedCaseInsensitiveContains(self.searchString) }
		}
	}

	private func sortLoadedTerritories() -> [PackageViewModel] {
		self.loadedPackages.sorted(by: {
			switch ($0.package.info.installed, $1.package.info.installed) {
				case (true, true), (false, false):
					return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
				case (false, true):
					return false
				case (true, false):
					return true
			}
		})
	}
}
