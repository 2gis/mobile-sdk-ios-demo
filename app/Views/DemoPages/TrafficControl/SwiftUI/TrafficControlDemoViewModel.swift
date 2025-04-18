import SwiftUI
import DGis

class TrafficControlDemoViewModel {
	var shouldSwitchTrafficControlState: Bool = false

	private enum Constants {
		static let mapState = "Global/MapStateWithTraffic"
	}

	private let map: Map
	private let logger: ILogger
	private lazy var storage: IKeyValueStorage = UserDefaults.standard

	init(
		map: Map,
		logger: ILogger
	) {
		self.map = map
		self.logger = logger

		self.restoreState()
	}

	func saveState() {
		let mapState = PackedMapState.fromMap(map: self.map)
		self.storage.set(mapState.toBytes().base64EncodedString(), forKey: Constants.mapState)
	}

	private func restoreState() {
		guard
			let rawValue: String = self.storage.value(forKey: Constants.mapState),
			let storedMapState = Data(base64Encoded: rawValue),
			let mapState = try? PackedMapState.fromBytes(data: storedMapState)
		else {
			return
		}

		do {
			try self.map.camera.setPosition(position: mapState.cameraPosition)
		} catch let error as SimpleError {
			self.logger.error("Failed to restore state: \(error.description)")
			return
		} catch {
			self.logger.error("Failed to restore state: \(error)")
			return
		}

		self.shouldSwitchTrafficControlState = mapState.showTraffic
	}
}
