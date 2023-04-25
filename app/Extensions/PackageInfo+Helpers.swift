import DGis

enum PackageStatus: Equatable {
	case preinstalled, installed, installing(progress: UInt8), notInstalled, notCompatible

	var description: String {
		switch self {
			case .preinstalled:
				return "Preinstalled"
			case .installing(let progress):
				return "Installing \(progress)%"
			case .notCompatible:
				return "Not compatible with current version"
			case .installed:
				return "Installed"
			case .notInstalled:
				return "Not installed"
		}
	}
}

extension Package {
	var status: PackageStatus {
		if self.info.installed {
			if self.info.updateStatus == .inProgress {
				return .installing(progress: self.progress)
			} else if self.info.compatible == false {
				return .notCompatible
			} else if self.info.preinstalled {
				return .preinstalled
			} else {
				return .installed
			}
		} else {
			return .notInstalled
		}
	}

	var isReadyToUse: Bool {
		self.info.preinstalled || (self.info.installed && !self.info.incomplete)
	}

	var isInstallingInProgress: Bool {
		self.info.installed && self.info.updateStatus == .inProgress
	}
}
