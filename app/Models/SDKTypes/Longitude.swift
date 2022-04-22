import DGis

extension Longitude {
	static func + (lhs: Longitude, rhs: Longitude) -> Longitude {
		Longitude(value: lhs.value + rhs.value)
	}

	static func - (lhs: Longitude, rhs: Longitude) -> Longitude {
		Longitude(value: lhs.value - rhs.value)
	}

	static func * (lhs: Longitude, rhs: Double) -> Self {
		Longitude(value: lhs.value * rhs)
	}

	static func * (lhs: Double, rhs: Longitude) -> Self {
		Longitude(value: lhs * rhs.value)
	}

	static func / (lhs: Longitude, rhs: Double) -> Self {
		precondition(rhs != 0)
		return Longitude(value: lhs.value / rhs)
	}

	static func <= (lhs: Longitude, rhs: Longitude) -> Bool {
		return lhs.value <= rhs.value
	}

	static func >= (lhs: Longitude, rhs: Longitude) -> Bool {
		return lhs.value >= rhs.value
	}
}
