import DGis
import Foundation

class TerritoryViewModel: ObservableObject, Identifiable, @unchecked Sendable {
	var title: String {
		self.package.info.name
	}

	@Published var dataToLoad: String = ""

	var downloadAvailable: Bool {
		self.package.info.installed == false || self.package.info.hasUpdate
	}

	var id: String {
		self.package.id
	}

	var uninstallAvailable: Bool {
		self.package.info.installed && !self.package.info.preinstalled
	}

	let package: DGis.Territory

	@Published private(set) var status: PackageStatus
	@Published var isUninstallRequestShown: Bool = false

	private let territoryManagerSettingsViewModel: TerritoryManagerSettingsViewModel
	private var infoCancellable: Cancellable = .init()
	private var progressCancellable: Cancellable = .init()

	init(
		package: DGis.Territory,
		territoryManagerSettingsViewModel: TerritoryManagerSettingsViewModel
	) {
		self.package = package
		self.status = package.status
		self.territoryManagerSettingsViewModel = territoryManagerSettingsViewModel

		self.progressCancellable = package.progressChannel.sinkOnMainThread {
			[weak self] _ in
			self?.updateStatus()
		}
		self.infoCancellable = package.infoChannel.sinkOnMainThread {
			[weak self] info in
			self?.dataToLoad = TerritoryViewModel.formatSize(info: info)
			self?.updateStatus()
		}
	}

	func install() {
		if !self.package.isInstallingInProgress {
			self.package.install(fallback: self.territoryManagerSettingsViewModel.makeInstallFallback())
		}
	}

	func uninstall() {
		self.package.uninstall()
	}

	func pause() {
		if self.package.isInstallingInProgress {
			self.package.pause()
		}
	}

	private func updateStatus() {
		let newStatus = self.package.status
		if newStatus != self.status {
			self.status = newStatus
		}
	}

	private static func formatSize(info: PackageInfo) -> String {
		guard let finalSize = info.finalSizeOnDisk else { return "NaN" }
		let currentSize = info.currentSizeOnDisk
		return self.byteCountFormatter.string(fromByteCount: Int64(finalSize - currentSize))
	}

	private static var byteCountFormatter: ByteCountFormatter {
		let formatter = ByteCountFormatter()
		formatter.allowedUnits = [.useMB, .useGB]
		formatter.countStyle = .memory
		return formatter
	}
}
