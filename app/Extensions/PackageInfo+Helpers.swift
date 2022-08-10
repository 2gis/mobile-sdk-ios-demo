import DGis

enum PackageStatus: Equatable {
	case preinstalled, installed, installing(progress: UInt8), notInstalled, notCompatible

	var description: String {
		switch self {
			case .preinstalled:
				return "Предустановлен"
			case .installing(let progress):
				return "Установка \(progress)%"
			case .notCompatible:
				return "Не совместим с текущей версией"
			case .installed:
				return "Установлен"
			case .notInstalled:
				return "Не установлен"
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
