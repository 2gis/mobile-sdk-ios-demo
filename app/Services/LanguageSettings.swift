import Foundation
import DGis

enum Language: String, CaseIterable, Identifiable {
	case en, ru, ar, system

	var id: String {
		return self.rawValue
	}
}

extension Language {
	static let `default`: Language = {
		return .en
	}()

	var name: String {
		switch self {
			case .en:
				return "English"
			case .ru:
				return "Russian"
			case .ar:
				return "Arabic"
			case .system:
				return "System"
		}
	}

	var locale: DGis.Locale? {
		switch self {
			case .en:
				return "en-US"
			case .ru:
				return "ru-RU"
			case .ar:
				return "ar-AE"
			case .system:
				return nil
		}
	}

	func next() -> Language {
		guard let index = Language.allCases.firstIndex(of: self) else {
			return Language.allCases[0]
		}
		if index + 1 < Language.allCases.count {
			return Language.allCases[index + 1]
		} else {
			return Language.allCases[0]
		}
	}
}
