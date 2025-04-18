import Combine
import DGis

class PackageViewModel: ObservableObject, Identifiable {
	var name: String {
		self.package is DGis.RoadMacroGraph ? "Road Macro Graph" : self.package.info.name
	}
	var downloadAvailable: Bool {
		self.package.info.installed == false || self.package.info.hasUpdate
	}
	var id: String {
		self.package.id
	}
	var uninstallAvailable: Bool {
		self.package.info.installed && !self.package.info.preinstalled
	}
	let package: DGis.Package

	@Published private(set) var status: PackageStatus
	@Published var isUninstallRequestShown: Bool = false

	private var infoCancellable: ICancellable = NoopCancellable()
	private var progressCancellable: ICancellable = NoopCancellable()

	init(package: DGis.Package) {
		self.package = package
		self.status = package.status

		self.progressCancellable = package.progressChannel.sinkOnMainThread({
			[weak self] progress in
			self?.updateStatus()
		})
		self.infoCancellable = package.infoChannel.sinkOnMainThread({
			[weak self] info in
			self?.updateStatus()
		})
	}

	func install() {
		if !self.package.isInstallingInProgress {
			self.package.install()
		}
	}

	func uninstall() {
		self.package.uninstall()
	}

	private func updateStatus() {
		let newStatus = self.package.status
		if newStatus != self.status {
			self.status = newStatus
		}
	}
}
