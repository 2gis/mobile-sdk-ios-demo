import DGis

extension RenderedObjectInfo: CustomStringConvertible {

	public var description: String {
		let pointDescription = self.closestMapPoint.description
		switch self.item.item {
			case let dgisMapObject as DgisMapObject:
				return "Id: \(dgisMapObject.id)"
			case let cluster as ClusterObject:
				return "Objects count: \(cluster.objectCount)"
			case is MyLocationMapObject, is GeometryMapObject:
				return pointDescription
			default:
				return pointDescription
		}
	}
}
