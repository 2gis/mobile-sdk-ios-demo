import DGis

extension Latitude {
	static func + (lhs: Latitude, rhs: Latitude) -> Latitude {
		Latitude(value: lhs.value + rhs.value)
	}

	static func - (lhs: Latitude, rhs: Latitude) -> Latitude {
		Latitude(value: lhs.value - rhs.value)
	}

	static func * (lhs: Latitude, rhs: Double) -> Self {
		Latitude(value: lhs.value * rhs)
	}

	static func * (lhs: Double, rhs: Latitude) -> Self {
		Latitude(value: lhs * rhs.value)
	}

	static func / (lhs: Latitude, rhs: Double) -> Self {
		precondition(rhs != 0)
		return Latitude(value: lhs.value / rhs)
	}

	static func <= (lhs: Latitude, rhs: Latitude) -> Bool {
		return lhs.value <= rhs.value
	}

	static func >= (lhs: Latitude, rhs: Latitude) -> Bool {
		return lhs.value >= rhs.value
	}
}
