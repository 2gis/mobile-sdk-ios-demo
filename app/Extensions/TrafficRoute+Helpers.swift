import DGis

extension TrafficRoute {
	public var description: String {
		"Distance: \(self.route.geometry.length.millimeters / 1000)m"
	}
}
