import DGis

extension TrafficRoute: CustomStringConvertible {
	public var description: String {
		"Distance: \(self.route.geometry.length.millimeters / 1000)m"
	}
}
