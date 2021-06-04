import SwiftUI

struct DirectoryObjectView: View {
	let viewModel: DirectoryObjectViewModel

	var body: some View {
		HStack {
			VStack(alignment: .leading) {
				Divider()
				Text(self.viewModel.title)
					.font(.headline)
				Text(self.viewModel.subtitle)
					.font(.subheadline)
				self.viewModel.address.map(FormattedAddressView.init)?
					.padding([.top, .bottom], 8)
					.foregroundColor(.gray)
				Divider()
			}
			Spacer()
		}
		.padding()
		.navigationBarTitle(self.viewModel.navigationTitle)
	}
}
