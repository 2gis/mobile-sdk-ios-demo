import SwiftUI
import Combine
import PlatformSDK

extension PlatformSDK.Future {
	public func sinkOnMainThread(
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

	public func asCombineFuture() -> Combine.Future<Value, Error> {
		Combine.Future { [self] promise in
			// Keep cancellable reference until either handler is called.
			// Combine.Future does not directly handle cancellation.
			var cancellable: PlatformSDK.Cancellable?
			cancellable = self.sink {
				promise(.success($0))
				_ = cancellable
			} failure: {
				promise(.failure($0))
				_ = cancellable
			}
		}
	}
}
