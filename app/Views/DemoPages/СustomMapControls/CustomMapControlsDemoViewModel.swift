import SwiftUI
import Combine
import PlatformSDK

final class CustomMapControlsDemoViewModel: ObservableObject {
	enum MapControlsType: CaseIterable, Identifiable {
		case `default`, custom

		var id: MapControlsType { self }
		var title: String {
			switch self {
				case .default:
					return "Контролы по умолчанию"
				case .custom:
					return "Кастомные контролы"
			}
		}
	}

	@Published var controlsType: MapControlsType = .custom
	let controlTypes: [MapControlsType] = MapControlsType.allCases

	init() {}
}
