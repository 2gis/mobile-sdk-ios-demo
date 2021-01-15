import SwiftUI
import Combine

final class SearchStore: ObservableObject {
	var dispatcher: Dispatcher {
		{ [weak self] in self?.dispatch($0) }
	}

	@Published private(set) var state: SearchState
	private let reducer: SearchReducer

	init(initialState: SearchState, reducer: SearchReducer) {
		self.state = initialState
		self.reducer = reducer
	}

	func dispatch(_ action: SearchAction) {
		let result = self.reducer(state: &self.state, action: action)
		self.handle(result)
	}

	func handle(_ result: ReducerResult) {
		switch result {
			case .completed:
				break
			case .continuation(let thunk):
				thunk(self.dispatcher)
		}
	}
}

extension SearchStore {

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
