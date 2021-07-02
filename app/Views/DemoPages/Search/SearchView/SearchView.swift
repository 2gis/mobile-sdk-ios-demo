import SwiftUI
import DGis

struct SearchView: View {
	@ObservedObject var store: SearchStore

    var body: some View {
		Group {
			TextField(
				"Enter...",
				text: self.store.bind(\.queryText) { .setQueryText($0) },
				onCommit: { self.store.dispatch(.search) }
			)
			.frame(minHeight: 44)
			.padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
			.background(
				RoundedRectangle(cornerRadius: 8)
				.strokeBorder(Color.gray, lineWidth: 1)
			)
			.padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))

			if !self.store.state.suggestion.isEmpty {
				SuggestResultView(
					dispatcher: self.store.dispatcher,
					viewModel: self.store.state.suggestion,
					navigation: self.store.bind(\.navigation) { .navigate($0) }
				)
				Divider()
			} else if !self.store.state.result.isEmpty {
				SearchResultView(
					viewModel: self.store.state.result,
					navigation: self.store.bind(\.navigation) { .navigate($0) }
				)
			} else {
				Spacer()
			}
		}
		.navigationBarTitle("Directory Search", displayMode: .inline)
    }
}
