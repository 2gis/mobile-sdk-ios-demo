import Combine
import DGis

class TerritoryViewModel: ObservableObject, Identifiable {
	var name: String {
		"\(self.territory.info.name)"
	}
	var downloadAvailable: Bool {
		self.territory.info.installed == false || self.territory.info.hasUpdate
	}
	var id: String {
		self.territory.id
	}
	var uninstallAvailable: Bool {
		self.territory.isReadyToUse && !self.territory.info.preinstalled
	}
	let territory: Territory

	@Published private(set) var status: PackageStatus
	@Published var isUninstallRequestShown: Bool = false

	private var infoCancellable: ICancellable = NoopCancellable()
	private var progressCancellable: ICancellable = NoopCancellable()

	init(territory: Territory) {
		self.territory = territory
		self.status = territory.status

		self.progressCancellable = territory.progressChannel.sinkOnMainThread {
			[weak self] progress in
			self?.updateStatus()
		}
		self.infoCancellable = territory.infoChannel.sinkOnMainThread {
			[weak self] info in
			self?.updateStatus()
		}
	}

	func install() {
		if !self.territory.isInstallingInProgress {
			self.territory.install()
		}
	}

	func uninstall() {
		self.territory.uninstall()
	}

	private func updateStatus() {
		let newStatus = self.territory.status
		if newStatus != self.status {
			self.status = newStatus
		}
	}
}
