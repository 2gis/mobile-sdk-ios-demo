import SwiftUI
import Combine
import DGis

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
			}
		}
	}

	@Published var controlsType: MapControlsType = .custom
	let controlTypes: [MapControlsType] = MapControlsType.allCases

	init() {}
}
