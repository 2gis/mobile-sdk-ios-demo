import Foundation

@propertyWrapper
struct Clamping<Value: Comparable> {
	var value: Value
	let range: ClosedRange<Value>

	init(wrappedValue initialValue: Value, _ range: ClosedRange<Value>) {
		precondition(range.contains(initialValue))
		self.value = initialValue
		self.range = range
	}

	var wrappedValue: Value {
		get {
			self.value
		}
		set {
			self.value = min(max(self.range.lowerBound, newValue), self.range.upperBound)
		}
	}
}
