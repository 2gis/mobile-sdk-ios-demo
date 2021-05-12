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
				return "Кастомные контролы карты"
			case .markers:
				return "Добавление маркеров на карту"
			case .mapStyles:
				return "Кастомные стили карты"
			case .mapObjectsIdentification:
				return "Идентификация объектов на карте"
			case .routeSearch:
				return "Поиск маршрута"
			case .search:
				return "Поиск в справочнике"
			case .visibleAreaDetection:
				return "Определение видимой области"
		}
	}
}

extension DemoPage: Identifiable {
	var id: String {
		return self.rawValue
	}
}
