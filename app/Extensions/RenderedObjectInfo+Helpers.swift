import DGis

extension RenderedObjectInfo {

	public var description: String {
		let pointDescription = self.closestMapPoint.description
		switch self.item.item {
			case let dgisMapObject as DgisMapObject:
				return "Id: \(dgisMapObject.id.objectId)"
			case let cluster as ClusterObject:
				return "Objects count: \(cluster.objectCount)"
			case is MyLocationMapObject, is GeometryMapObject:
				return pointDescription
			case let route as RouteMapObject:
				return route.route.description
			case let routePoint as RoutePointMapObject:
				return routePoint.route.description
			default:
				return pointDescription
		}
	}
}
