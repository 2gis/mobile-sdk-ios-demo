import Foundation
import Combine
import DGis

final class TerritoryManagerDemoViewModel: ObservableObject {
	private enum Constants {
		static let searchDelay: TimeInterval = 0.3
	}
	@Published private(set) var territories: [TerritoryViewModel] = []
	@Published var searchString: String = ""
	private var loadedTerritories: [TerritoryViewModel] = []
	private let packageManager: PackageManager
	private let territoryManager: TerritoryManager

	private var territoriesCancellable: ICancellable?
	private var searchStringCancellable: AnyCancellable?
	private var territoryStatusSubscriptions = Set<AnyCancellable>()

	init(
		packageManager: PackageManager,
		territoryManager: TerritoryManager
	) {
		self.packageManager = packageManager
		self.territoryManager = territoryManager

		self.territoriesCancellable = territoryManager.territoriesChannel.sinkOnMainThread {
			[weak self] _ in
			self?.updateTerritories()
		}
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
		self.loadedTerritories = self.territoryManager.territories.map {
			let viewModel = TerritoryViewModel(territory: $0)
			viewModel.$status
				.dropFirst()
				.filter { $0 == .installed || $0 == .notInstalled }
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
			self.territories = self.sortLoadedTerritories()
		} else {
			self.territories = self.sortLoadedTerritories().filter { $0.name.contains(self.searchString) }
		}
	}

	private func sortLoadedTerritories() -> [TerritoryViewModel] {
		self.loadedTerritories.sorted(by: {
			switch ($0.territory.isReadyToUse, $1.territory.isReadyToUse) {
				case (true, true), (false, false):
					return $0.name < $1.name
				case (false, true):
					return false
				case (true, false):
					return true
			}
		})
	}
}
