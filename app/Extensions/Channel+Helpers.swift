import SwiftUI
import PlatformMapSDK

extension Channel {
	@inlinable public func sinkOnMainThread(receiveValue: @escaping (Value) -> Void) -> PlatformMapSDK.Cancellable {
		self.sink { value in
			DispatchQueue.main.async {
				receiveValue(value)
			}
		}
	}
}
