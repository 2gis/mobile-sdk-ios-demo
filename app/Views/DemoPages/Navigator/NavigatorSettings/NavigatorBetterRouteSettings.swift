import Foundation
import DGis

struct NavigatorBetterRouteSettings {
	// Minimum time gain for an alternative route, seconds.
	var betterRouteTimeCostThreshold: TimeInterval = 0

	// Minimum length gain for an alternative route, meters.
	var betterRouteLengthThreshold: RouteDistance

	// Timeout for alternative route search. Must be at least 5 seconds.
	var routeSearchDefaultDelay: TimeInterval = 5
}
