import DGis

extension Arcdegree {
	static func + (lhs: Arcdegree, rhs: Arcdegree) -> Arcdegree {
		Arcdegree(value: lhs.value + rhs.value)
	}

	static func - (lhs: Arcdegree, rhs: Arcdegree) -> Arcdegree {
		Arcdegree(value: lhs.value - rhs.value)
	}

	static func * (lhs: Arcdegree, rhs: Double) -> Self {
		Arcdegree(value: lhs.value * rhs)
	}

	static func * (lhs: Double, rhs: Arcdegree) -> Self {
		Arcdegree(value: lhs * rhs.value)
	}

	static func / (lhs: Arcdegree, rhs: Double) -> Self {
		precondition(rhs != 0)
		return Arcdegree(value: lhs.value / rhs)
	}

	static func <= (lhs: Arcdegree, rhs: Arcdegree) -> Bool {
		return lhs.value <= rhs.value
	}

	static func >= (lhs: Arcdegree, rhs: Arcdegree) -> Bool {
		return lhs.value >= rhs.value
	}
}
