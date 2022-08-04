import Foundation

struct NavigatorOptions {
	enum Mode {
		case `default`, freeRoam, simulation
	}

	let mode: Mode
	let simulationSpeedKmH: Double
	let allowableSpeedExcessKmH: Float
}
