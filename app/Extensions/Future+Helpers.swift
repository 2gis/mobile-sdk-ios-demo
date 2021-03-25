import SwiftUI
import PlatformSDK

extension Future {

	@inlinable public func sinkOnMainThread(
		receiveValue: @escaping (Value) -> Void,
		failure: @escaping (Error) -> Void
	) -> PlatformSDK.Cancellable {
		self.sink { value in
			DispatchQueue.main.async {
				receiveValue(value)
			}
		} failure: { error in
			DispatchQueue.main.async {
				failure(error)
			}
		}
	}
}
