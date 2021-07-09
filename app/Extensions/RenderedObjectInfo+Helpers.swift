import DGis

extension RenderedObjectInfo: CustomStringConvertible {

	public var description: String {
		let pointDescription = self.closestMapPoint.description
		switch self.item.item {
			case let dgisMapObject as DgisMapObject:
				return "Id: \(dgisMapObject.id.value)"
			case let searchResult as SearchResultMarkerObject:
				if let id = searchResult.id {
					return "Id: \(id.value)"
				} else {
					return searchResult.markerPosition.description
				}
			case let cluster as ClusterObject:
				return "Objects count: \(cluster.objectCount)"
			case is MyLocationMapObject, is GeometryMapObject:
				return pointDescription
			default:
				return pointDescription
		}
	}
}
