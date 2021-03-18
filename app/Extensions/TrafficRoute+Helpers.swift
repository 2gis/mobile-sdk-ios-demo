import PlatformSDK

extension TrafficRoute: CustomStringConvertible {

	public var description: String {
		"Distance: \(self.length.millimeters * 1000)m"
	}
}
