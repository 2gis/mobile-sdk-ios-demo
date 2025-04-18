import Foundation
import DGis

struct FreeRoamSettings {
	/// Расстояние кэширования тайлов на маршруте.
	/// Задается в метрах.
	var cacheDistanceOnRoute: RouteDistance = RouteDistance(millimeters: 0)

	/// Радиус кэширования тайлов на маршруте.
	/// Задается в метрах.
	var cacheRadiusOnRoute: Double = 0.0

	/// Радиус кэширования тайлов в режиме FreeRoam.
	/// Задается в метрах.
	var cacheRadiusInFreeRoam: Double = 0.0
}
