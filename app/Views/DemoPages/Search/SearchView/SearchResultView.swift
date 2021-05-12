import SwiftUI

struct SearchResultView: View {
	let viewModel: SearchResultViewModel
	@Binding var navigation: SearchNavigation?

	var body: some View {
		List(self.viewModel.items) { item in
			NavigationLink(
				destination: DirectoryObjectView(viewModel: item.object),
				tag: .openSearchResultItem(item.id),
				selection: self.$navigation
			) {
				SearchResultItemView(viewModel: item)
			}
		}
	}
}
