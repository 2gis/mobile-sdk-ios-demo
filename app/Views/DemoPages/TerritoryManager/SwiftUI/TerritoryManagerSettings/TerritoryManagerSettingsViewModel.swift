import Combine
import DGis
import Foundation

final class TerritoryManagerSettingsViewModel: ObservableObject {
	private enum Constants {
		static let installFallbackTypeState = "Global/InstallFallbackTypeState"
		static let installFallbackRetryCountState = "Global/InstallFallbackRetryCountState"
		static let defaultInstallFallbackRetryCount: UInt32 = 5
	}

	enum InstallFallbackType: String, CaseIterable, PickerViewOption {
		case noOperation, retryOnError

		var id: InstallFallbackType {
			self
		}

		var name: String {
			switch self {
			case .noOperation:
				return "NoOperation"
			case .retryOnError:
				return "RetryOnError"
			@unknown default:
				assertionFailure("Unknown type: \(self)")
				return "Unknown type: \(self)"
			}
		}
	}

	let installFallbackTypes: [InstallFallbackType]
	@Published var installFallbackType: InstallFallbackType = .noOperation
	@Published var installFallbackRetryCount: UInt32 = Constants.defaultInstallFallbackRetryCount

	private let logger: ILogger

	private lazy var storage: IKeyValueStorage = UserDefaults.standard

	init(
		logger: ILogger,
		installFallbackTypes: [InstallFallbackType] = InstallFallbackType.allCases
	) {
		self.logger = logger
		self.installFallbackTypes = installFallbackTypes
		self.restoreTerritoryManagerState()
	}

	func saveState() {
		self.storage.set(self.installFallbackType.rawValue, forKey: Constants.installFallbackTypeState)
		self.storage.set(self.installFallbackRetryCount, forKey: Constants.installFallbackRetryCountState)
	}

	func makeInstallFallback() -> InstallFallback {
		switch self.installFallbackType {
		case .noOperation:
			return DefaultInstallFallback.noOperation()
		case .retryOnError:
			return CustomInstallFallback(
				logger: self.logger,
				retryCount: self.installFallbackRetryCount
			)
		@unknown default:
			fatalError("Unknown type: \(self)")
		}
	}

	private func restoreTerritoryManagerState() {
		if let installFallbackTypeRawValue: String = self.storage.value(forKey: Constants.installFallbackTypeState),
		   let type = InstallFallbackType(rawValue: installFallbackTypeRawValue)
		{
			self.installFallbackType = type
		}

		self.installFallbackRetryCount = self.storage.value(forKey: Constants.installFallbackRetryCountState) ?? Constants.defaultInstallFallbackRetryCount
	}
}

private class CustomInstallFallback: InstallFallback {
	private let logger: ILogger
	private let defaultInstallFallback: InstallFallback
	private var attemptNumber: UInt32 = 1

	init(
		logger: ILogger,
		retryCount: UInt32
	) {
		self.logger = logger
		self.defaultInstallFallback = DefaultInstallFallback.retryOnError(retryCount: UInt64(retryCount))
	}

	func process(targetPackage: DGis.Package) {
		self.logger.error("[TerritoryManagerSettingsViewModel] DefaultInstallFallback.retryOnError: \(self.attemptNumber)")
		self.defaultInstallFallback.process(targetPackage: targetPackage)
		self.attemptNumber += 1
	}
}
