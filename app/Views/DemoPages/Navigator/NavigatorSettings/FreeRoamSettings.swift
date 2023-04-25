import Foundation
import DGis

struct FreeRoamSettings {
	/// Caching distance of tiles on the route.
	/// Specified in meters.
	var cacheDistanceOnRoute: RouteDistance = RouteDistance(millimeters: 0)

	/// Caching radius of tiles on the route.
	/// Specified in meters.
	var cacheRadiusOnRoute: Double = 0.0

	/// Caching radius of tiles in FreeRoam mode.
	/// Specified in meters.
	var cacheRadiusInFreeRoam: Double = 0.0
}
