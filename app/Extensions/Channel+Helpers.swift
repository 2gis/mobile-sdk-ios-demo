import SwiftUI
import DGis

extension Channel {
	@inlinable public func sinkOnMainThread(receiveValue: @escaping (Value) -> Void) -> DGis.Cancellable {
		self.sink { value in
			DispatchQueue.main.async {
				receiveValue(value)
			}
		}
	}
}
