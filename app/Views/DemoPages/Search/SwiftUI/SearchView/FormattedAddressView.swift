import SwiftUI

struct FormattedAddressView: View {
	let viewModel: FormattedAddressViewModel

	var body: some View {
		VStack(alignment: .leading) {
			self.viewModel.comment.map(Text.init)
			self.viewModel.street.map(Text.init)
			self.viewModel.drilldown.map(Text.init)
			self.viewModel.postCode.map(Text.init)
			self.viewModel.fiasCodes.map{ Text("Street fias codes: " + $0) }
		}
	}
}
