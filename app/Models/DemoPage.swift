enum DemoPage: String, CaseIterable {
	case camera
	case visibleAreaDetection
	case mapObjectsIdentification
	case markers
	case customMapControls
	case mapStyles
	case mapTheme
	case dictionarySearch
	case fps
	case clustering
	case customGestures

	var name: String {
		switch self {
			case .camera:
				return "Перелеты камеры"
			case .customMapControls:
				return "Пользовательские кнопки управления картой"
			case .markers:
				return "Добавление маркеров на карту"
			case .mapStyles:
				return "Пользовательские стили карты"
			case .mapTheme:
				return "Переключение темы стиля карты"
			case .mapObjectsIdentification:
				return "Определение объектов на карте"
			case .dictionarySearch:
				return "Поиск в справочнике"
			case .visibleAreaDetection:
				return "Определение выхода из области"
			case .fps:
				return "Установка максимального fps"
			case .clustering:
				return "Динамическая кластеризация"
			case .customGestures:
				return "Пользовательские жесты управления картой"
		}
	}
}

extension DemoPage: Identifiable {
	var id: String {
		return self.rawValue
	}
}
