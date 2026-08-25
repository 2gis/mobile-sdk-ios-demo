import Foundation
import DGis

final class NavigatorBetterRouteSettings {
	// Минимальная разница во времени движения между исходным маршрутом и альтернативным маршрутом,
	// при которой альтернативный маршрут считается маршрутом лучше.
	private var _betterRouteTimeCostThreshold: TimeInterval = 0
	var betterRouteTimeCostThreshold: TimeInterval {
		get { _betterRouteTimeCostThreshold }
		set { _betterRouteTimeCostThreshold = max(0, newValue) }
	}

	// Минимальная суммарная длина рёбер маршрута, которые отличаются между исходным маршрутом и альтернативным маршрутом,
	// при которой альтернативный маршрут считается маршрутом лучше.
	var betterRouteLengthThreshold: RouteDistance

	// Задержка перед поиском альтернативных маршрутов при старте поездки по маршруту или после перехода на предложенный маршрут.
	// Должна быть не меньше 5 секунд.
	private var _routeSearchDefaultDelay: TimeInterval = 5
	var routeSearchDefaultDelay: TimeInterval {
		get { _routeSearchDefaultDelay }
		set { _routeSearchDefaultDelay = max(5, newValue) }
	}

	init(
		betterRouteTimeCostThreshold: TimeInterval = 0,
		betterRouteLengthThreshold: RouteDistance,
		routeSearchDefaultDelay: TimeInterval = 5
	) {
		self._betterRouteTimeCostThreshold = max(0, betterRouteTimeCostThreshold)
		self.betterRouteLengthThreshold = betterRouteLengthThreshold
		self._routeSearchDefaultDelay = max(5, routeSearchDefaultDelay)
	}
}
