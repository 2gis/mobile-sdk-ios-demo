import DGis
import Foundation

enum PackageStatus: Equatable {
	case preinstalled,
	     installed,
	     installing(progress: UInt8),
	     notInstalled,
	     notCompatible,
	     paused,
	     hasUpdate

	var description: String {
		switch self {
		case .preinstalled:
			return "Preinstalled"
		case .installing:
			return "Loading"
		case .notCompatible:
			return "Isn't compatible"
		case .installed:
			return "Installed"
		case .notInstalled:
			return "Not installed"
		case .paused:
			return "Paused"
		case .hasUpdate:
			return "Has update"
		@unknown default:
			assertionFailure("Unknown value for PackageStatus")
		}
	}
}

extension Package {
	var status: PackageStatus {
		if self.info.installed {
			if self.info.updateStatus == .inProgress {
				.installing(progress: self.progress)
			} else if self.info.updateStatus == .paused {
				.paused
			} else if self.info.hasUpdate {
				.hasUpdate
			} else if self.info.compatible == false {
				.notCompatible
			} else if self.info.preinstalled {
				.preinstalled
			} else {
				.installed
			}
		} else {
			.notInstalled
		}
	}

	var isReadyToUse: Bool {
		self.info.preinstalled || (self.info.installed && !self.info.incomplete)
	}

	var isInstallingInProgress: Bool {
		self.info.installed && self.info.updateStatus == .inProgress
	}
}
