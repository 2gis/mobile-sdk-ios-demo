import Combine
import DGis
import SwiftUI

final class CustomMapControlsDemoViewModel: ObservableObject {
	enum MapControlsType: CaseIterable, Identifiable {
		case `default`, custom

		var id: MapControlsType { self }
		var title: String {
			switch self {
			case .default:
				return "Default"
			case .custom:
				return "Custom"
			@unknown default:
				fatalError("Unknown type: \(self)")
			}
		}
	}

	@Published var controlsType: MapControlsType = .custom
	let controlTypes: [MapControlsType] = MapControlsType.allCases

	init() {}
}
