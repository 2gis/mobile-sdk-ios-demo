import Foundation
import Combine
import DGis

final class NavigatorSettingsViewModel: ObservableObject {
	private enum Constants {
		static let navigationState = "Global/NavigationState"
		static let isSimulationState = "Global/IsNavigationSimulationState"
		static let simulationSpeedKmHState = "Global/SimulationSpeedKmHState"
		static let defaultSimulationSpeedKmH: Double = 60.0
		static let defaultMaxSimulationSpeedKmH: Double = 508
		static let defaultAllowableSpeedExcessKmH: Float = 15
		static let defaultMaxAllowableSpeedExcessKmH: Float = 20
	}

	enum DemoRouteType: CaseIterable, PickerViewOption {
		case car, bicycle, pedestrian

		var id: DemoRouteType { self }

		var name: String {
			switch self {
				case .car:
					return "Car"
				case .bicycle:
					return "Bicycle"
				case .pedestrian:
					return "Pedestrian"
			}
		}

		var routeSearchOptions: RouteSearchOptions {
			switch self {
				case .car:
					return RouteSearchOptions.car(CarRouteSearchOptions())
				case .bicycle:
					return RouteSearchOptions.bicycle(BicycleRouteSearchOptions())
				case .pedestrian:
					return RouteSearchOptions.pedestrian(PedestrianRouteSearchOptions())
			}
		}
	}

	let maxSimulationSpeedKmH: Double
	let maxAllowableSpeedExcessKmH: Float
	@Published var showNavigatorVoicesSettings: Bool = false
	@Published var isSimulation: Bool
	@Published var isFreeRoam: Bool
	@Published var simulationSpeedKmH: Double
	@Published var allowableSpeedExcessKmH: Float
	@Published private(set) var voiceRows: [VoiceRowViewModel] = []
	@Published var currentVoice: Voice? {
		didSet {
			if oldValue != self.currentVoice {
				self.navigatorSettings.voiceId = self.currentVoice?.id
			}
		}
	}
	let routeTypeSources: [DemoRouteType]
	@Published var routeType: DemoRouteType = .car
	var navigatorOptions: NavigatorOptions {
		NavigatorOptions(
			isSimulation: self.isSimulation,
			isFreeRoam: self.isFreeRoam,
			simulationSpeedKmH: self.simulationSpeedKmH,
			allowableSpeedExcessKmH: self.allowableSpeedExcessKmH
		)
	}
	var navigationState: PackedNavigationState? = nil
	@Published var styleZoomFollowControllerType: StyleZoomFollowControllerType
	@Published var showBetterRouteSettings: Bool = false
	@Published var betterRouteSettings: NavigatorBetterRouteSettings
	@Published var showFreeRoamSettings: Bool = false
	@Published var freeRoamSettings: FreeRoamSettings
	let styleZoomFollowControllerTypes: [StyleZoomFollowControllerType]

	private let voiceManager: VoiceManager
	private let navigatorSettings: INavigatorSettings
	private lazy var storage: IKeyValueStorage = UserDefaults.standard

	init(
		voiceManager: VoiceManager,
		navigatorSettings: INavigatorSettings,
		isSimulation: Bool = false,
		isFreeRoam: Bool = false,
		simulationSpeedKmH: Double = Constants.defaultSimulationSpeedKmH,
		maxSimulationSpeedKmH: Double = Constants.defaultMaxSimulationSpeedKmH,
		allowableSpeedExcessKmH: Float = Constants.defaultAllowableSpeedExcessKmH,
		maxAllowableSpeedExcessKmH: Float = Constants.defaultMaxAllowableSpeedExcessKmH,
		routeTypeSources: [DemoRouteType] = DemoRouteType.allCases,
		styleZoomFollowControllerType: StyleZoomFollowControllerType,
		styleZoomFollowControllerTypes: [StyleZoomFollowControllerType] =  StyleZoomFollowControllerType.allCases,
		betterRouteSettings: NavigatorBetterRouteSettings,
		freeRoamSettings: FreeRoamSettings
	) {
		self.voiceManager = voiceManager
		self.navigatorSettings = navigatorSettings
		self.isSimulation = isSimulation
		self.isFreeRoam = isFreeRoam
		self.simulationSpeedKmH = simulationSpeedKmH
		self.maxSimulationSpeedKmH = maxSimulationSpeedKmH
		self.allowableSpeedExcessKmH = allowableSpeedExcessKmH
		self.maxAllowableSpeedExcessKmH = maxAllowableSpeedExcessKmH
		self.routeTypeSources = routeTypeSources
		self.styleZoomFollowControllerType = styleZoomFollowControllerType
		self.styleZoomFollowControllerTypes = styleZoomFollowControllerTypes
		self.betterRouteSettings = betterRouteSettings
		self.freeRoamSettings = freeRoamSettings

		self.setupNavigationVoice(initialVoiceId: self.navigatorSettings.voiceId)
		self.restoreNavigationState()
	}

	func select(_ row: VoiceRowViewModel) {
		if row.voice.isReadyToUse {
			self.currentVoice = row.voice
			self.updateSelectedVoiceRow()
			_ = row.voice.playWelcome()
		} else {
			row.install()
			self.updateVoiceRows()
		}
	}

	func saveState(uiModel: Model) {
		let navigationState = PackedNavigationState.fromModel(model: uiModel)
		self.storage.set(navigationState.toBytes().base64EncodedString(), forKey: Constants.navigationState)

		self.storage.set(self.isSimulation, forKey: Constants.isSimulationState)
		self.storage.set(self.simulationSpeedKmH, forKey: Constants.simulationSpeedKmHState)
	}

	private func restoreNavigationState() {
		if let navigationRawValue: String = self.storage.value(forKey: Constants.navigationState),
		   let storedNavigationState = Data(base64Encoded: navigationRawValue) {
			self.navigationState = try? PackedNavigationState.fromBytes(data: storedNavigationState)
		}

		if let navigationState = self.navigationState {
			self.isFreeRoam = navigationState.state != .disabled && navigationState.finishPoint != nil
		}

		self.isSimulation = self.storage.value(forKey: Constants.isSimulationState) ?? false
		self.simulationSpeedKmH = self.storage.value(forKey: Constants.simulationSpeedKmHState) ?? Constants.defaultSimulationSpeedKmH
	}

	private func updateSelectedVoiceRow() {
		for row in self.voiceRows {
			row.isSelected = self.currentVoice == row.voice
		}
	}

	private func didUninstallVoice(_ voice: Voice) {
		if voice == self.currentVoice {
			self.currentVoice = self.voiceManager.firstPreinstalledVoice
			self.updateSelectedVoiceRow()
		}
		self.updateVoiceRows()
	}
	
	private func updateVoiceRows() {
		self.voiceRows = self.voiceRows.map { $0 }
	}

	private func setupNavigationVoice(initialVoiceId: String?) {
		guard let preinstalledVoice = self.voiceManager.firstPreinstalledVoice else { return }

		if let userVoice = self.voiceManager.voices.first(where: { $0.id == initialVoiceId }) {
			self.currentVoice = userVoice
		} else {
			// Конфигурируем навигатор первым установленным голосом.
			self.currentVoice = preinstalledVoice
			self.navigatorSettings.voiceId = preinstalledVoice.id
		}

		self.voiceRows = self.voiceManager.voices.map {
			let viewModel = VoiceRowViewModel(voice: $0, isSelected: $0 == self.currentVoice)
			viewModel.uninstallVoiceCallback = { [weak self] voice in
				self?.didUninstallVoice(voice)
			}
			return viewModel
		}
	}
}

private extension VoiceManager {
	var firstPreinstalledVoice: Voice? {
		self.voices.first(where: { $0.info.preinstalled })
	}
}

private extension NavigatorOptions {
	init(
		isSimulation: Bool,
		isFreeRoam: Bool,
		simulationSpeedKmH: Double,
		allowableSpeedExcessKmH: Float
	) {
		let mode: Mode
		if isFreeRoam {
			mode = .freeRoam
		} else if isSimulation {
			mode = .simulation
		} else {
			mode = .default
		}
		self.init(
			mode: mode,
			simulationSpeedKmH: simulationSpeedKmH,
			allowableSpeedExcessKmH: allowableSpeedExcessKmH
		)
	}
}
