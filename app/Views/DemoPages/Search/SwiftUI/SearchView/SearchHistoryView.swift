import SwiftUI

struct SearchHistoryView: View {
	private enum Constants {
		static let trashImageWidth: CGFloat = 20
		static let trashImageHeight: CGFloat = 20
	}

	let dispatcher: Dispatcher
	let viewModel: SearchHistoryViewModel
	@Binding var navigation: SearchNavigation?

	var body: some View {
		ScrollView {
			Divider()

			ForEach(self.viewModel.items) { item in
				HStack {
					self.searchHistoryItemView(item: item)

					Spacer()

					self.removeItemButton(item: item)
				}
				.padding([.leading, .trailing])

				Divider()
			}
		}
	}

	private func searchHistoryItemView(item: SearchHistoryItemViewModel) -> some View {
		ZStack {
			Button (
				action: { self.dispatcher(.handleSearchHistoryItem(item)) },
				label: {
					SearchHistoryItemView(viewModel: item)
				}
			)

			if let objectViewModel = item.objectViewModel {
				NavigationLink(
					destination: DirectoryObjectView(viewModel: objectViewModel).onDisappear{ self.dispatcher(.getHistory) },
					tag: SearchNavigation.openDirectoryObject(objectViewModel.id),
					selection: self.$navigation,
					label: { EmptyView() }
				)
				.hidden()
				.frame(width:0)
			}
		}
	}

	private func removeItemButton(item: SearchHistoryItemViewModel) -> some View {
		Button (
			action: { self.dispatcher(.removeSearchHistoryItem(item)) },
			label: {
				Image(systemName: "trash")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(
						width: Constants.trashImageWidth,
						height: Constants.trashImageHeight
					)
			}
		)
	}
}
