enum DemoPage: String, CaseIterable {
	case camera
	case visibleAreaDetection
	case mapObjectsIdentification
	case markers
	case customMapControls
	case mapStyles
	case routeSearch
	case search

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
			case .mapObjectsIdentification:
				return "Определение объектов на карте"
			case .routeSearch:
				return "Поиск маршрута"
			case .search:
				return "Поиск в справочнике"
			case .visibleAreaDetection:
				return "Определение выхода из области"
		}
	}
}

extension DemoPage: Identifiable {
	var id: String {
		return self.rawValue
	}
}
