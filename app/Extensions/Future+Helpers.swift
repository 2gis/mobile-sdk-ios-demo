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
			let cancelHolder = Holder()
			cancelHolder.cancellable = self.sink {
				promise(.success($0))
				_ = cancelHolder
			} failure: {
				promise(.failure($0))
				_ = cancelHolder
			}
		}
	}

	private final class Holder {
		var cancellable: PlatformSDK.Cancellable?
	}
}
