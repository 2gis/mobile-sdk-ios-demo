import Foundation
import DGis

enum Language: String, CaseIterable, Identifiable {
	case system, ru, en, ar

	var id: String {
		return self.rawValue
	}
}

extension Language {
	static let `default`: Language = {
		return .system
	}()

	var name: String {
		switch self {
			case .system:
				return "System"
			case .ru:
				return "Russian"
			case .en:
				return "English"
			case .ar:
				return "Arabic"
		}
	}

	var locale: DGis.Locale? {
		switch self {
			case .system:
				return nil
			case .ru:
				return .init(language: "ru", region: "RU")
			case .en:
				return .init(language: "en", region: "US")
			case .ar:
				return .init(language: "ar", region: "SA")
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

protocol ILanguageSettings: AnyObject {
	var currentLanguage: Language { get }
	var supportedLanguages: [Language] { get }

	func setCurrentLanguage(_ language: Language)
}

class LanguageSettings: ILanguageSettings {
	let supportedLanguages: [Language]
	private(set) var currentLanguage: Language

	init(supportedLanguages: [Language] = Language.allCases) {
		self.currentLanguage = supportedLanguages.first ?? .en
		self.supportedLanguages = supportedLanguages
	}

	func setCurrentLanguage(_ language: Language) {
		guard self.supportedLanguages.contains(language) else { return }
		self.currentLanguage = language
	}
}
