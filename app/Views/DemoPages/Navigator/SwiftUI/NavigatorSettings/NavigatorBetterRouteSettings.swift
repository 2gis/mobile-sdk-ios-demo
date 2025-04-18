import Foundation
import DGis

struct NavigatorBetterRouteSettings {
	// Минимальная разница во времени движения между исходным маршрутом и альтернативным маршрутом,
	// при которой альтернативный маршрут считается маршрутом лучше.
	@Clamping(0...TimeInterval.greatestFiniteMagnitude)
	var betterRouteTimeCostThreshold: TimeInterval = 0

	// Минимальная суммарная длина рёбер маршрута, которые отличаются между исходным маршрутом и альтернативным маршрутом,
	// при которой альтернативный маршрут считается маршрутом лучше.
	var betterRouteLengthThreshold: RouteDistance

	// Задержка перед поиском альтернативных маршрутов при старте поездки по маршруту или после перехода на предложенный маршрут.
	// Должна быть не меньше 5 секунд.
	@Clamping(5...TimeInterval.greatestFiniteMagnitude)
	var routeSearchDefaultDelay: TimeInterval = 5
}
