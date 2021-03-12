import SwiftUI
import PlatformSDK

extension Channel {
	@inlinable public func sinkOnMainThread(receiveValue: @escaping (Value) -> Void) -> PlatformSDK.Cancellable {
		self.sink { value in
			DispatchQueue.main.async {
				receiveValue(value)
			}
		}
	}
}
