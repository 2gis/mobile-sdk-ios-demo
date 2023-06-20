import SwiftUI
import DGis

struct SearchView: View {
	@ObservedObject var store: SearchStore
	@SwiftUI.State private var isFilterShown: Bool = false

	var body: some View {
		Group {
			HStack {
				TextField(
					"Enter...",
					text: self.store.bind(\.queryText) { .setQueryText($0) },
					onCommit: { self.store.dispatch(.search) }
				)
				Button {
					self.isFilterShown = true
				} label: {
					Image(systemName: "slider.horizontal.3")
					.resizable()
					.frame(width: 20, height: 20)
				}
				.padding(.trailing, 5)
			}
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
		.sheet(isPresented: self.$isFilterShown) {
			SearchOptionsView(
				searchOptions: self.store.state.searchOptions ?? SearchOptions(),
				isPresented: self.$isFilterShown
			) { options in
				self.store.dispatch(.setSearchOptions(options))
			}
		}
		.navigationBarTitle("Directory Search", displayMode: .inline)
		.alert(isPresented: self.$store.state.isErrorAlertShown) {
			Alert(title: Text(self.store.state.errorMessage))
		}
	}
}
