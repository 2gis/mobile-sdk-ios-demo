import Combine
import SwiftUI

final class SearchStore: ObservableObject, @unchecked Sendable {
	@MainActor
	var dispatcher: Dispatcher {
		{ [weak self] action in
			Task { @MainActor in
				self?.dispatch(action)
			}
		}
	}

	@Published var state: SearchState
	private let reducer: SearchReducer

	init(initialState: SearchState, reducer: SearchReducer) {
		self.state = initialState
		self.reducer = reducer
	}

	@MainActor
	func dispatch(_ action: SearchAction) {
		let result = self.reducer(state: &self.state, action: action)
		self.handle(result)
	}

	@MainActor
	func handle(_ result: ReducerResult) {
		switch result {
		case .completed:
			break
		case let .continuation(thunk):
			thunk(self.dispatcher)
		@unknown default:
			assertionFailure("Unknown value for ReducerResult")
		}
	}
}

extension SearchStore {
	@MainActor
	func bind<Value>(
		_ keyPath: KeyPath<SearchState, Value>,
		feedback makeMutation: @escaping (Value) -> SearchAction
	) -> Binding<Value> {
		Binding<Value>(
			get: { self.state[keyPath: keyPath] },
			set: { self.dispatch(makeMutation($0)) }
		)
	}
}
