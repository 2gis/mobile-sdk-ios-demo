import SwiftUI

struct SuggestResultView: View {
	let dispatcher: Dispatcher
	let viewModel: SuggestResultViewModel
	@Binding var navigation: SearchNavigation?

	var body: some View {
		List(self.viewModel.suggests) { suggest in
			Group {
				Button {
					self.dispatcher(.handleSuggest(suggest))
				}
				label: {
					SuggestView(viewModel: suggest)
				}
				if let object = suggest.object {
					NavigationLink(
						destination: DirectoryObjectView(viewModel: object),
						tag: SearchNavigation.openSuggest(suggest.id),
						selection: self.$navigation,
						label: { EmptyView() }
					)
					.hidden()
					.frame(width: 0)
				}
			}
		}
	}
}
