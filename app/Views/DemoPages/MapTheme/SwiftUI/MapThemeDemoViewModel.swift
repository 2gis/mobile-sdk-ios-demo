import Combine
import DGis
import SwiftUI

final class MapThemeDemoViewModel: ObservableObject {
	@Published var showActionSheet = false
	@Published var currentTheme: MapTheme = .default {
		didSet {
			guard self.currentTheme != oldValue else { return }
			self.updateMapAppearance()
		}
	}
	let availableThemes: [MapTheme] = MapTheme.allCases

	private let mapFactory: IMapFactory
	private let logger: ILogger
	private var configureMapTask: Task<Void, Never>?

	init(mapFactory: IMapFactory, logger: ILogger) {
		self.mapFactory = mapFactory
		self.logger = logger
		self.configureMapTask = Task { @MainActor [weak self] in
			guard let self else { return }
			do {
				let map = try await self.mapFactory.mapAsync
				map.appearance = self.currentTheme.mapAppearance
			} catch {
				self.logger.error("Failed to configure map theme: \(error.localizedDescription)")
			}
		}
	}

	deinit {
		self.configureMapTask?.cancel()
	}

	private func updateMapAppearance() {
		Task { @MainActor [weak self] in
			guard let self else { return }
			do {
				let map = try await self.mapFactory.mapAsync
				map.appearance = self.currentTheme.mapAppearance
			} catch {
				self.logger.error("Failed to update map theme: \(error.localizedDescription)")
			}
		}
	}
}

