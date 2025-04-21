import SwiftUI

struct SearchResultView: View {
	@ObservedObject var viewModel: SearchResultViewModel
	@Binding var navigation: SearchNavigation?

	var body: some View {
		List(self.viewModel.items.indices, id: \.self) { index in
			let item = self.viewModel.items[index]
			NavigationLink(
				destination: DirectoryObjectView(viewModel: item.object),
				tag: .openSearchResultItem(item.id),
				selection: self.$navigation
			) {
				SearchResultItemView(viewModel: item)
					.onAppear {
						if index == self.viewModel.items.count - 1 {
							self.viewModel.loadNextPage()
						}
					}
			}
		}
	}
}
