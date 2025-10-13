import SwiftUI

struct TerritoryManagerSettingsView: View {
	@ObservedObject private var viewModel: TerritoryManagerSettingsViewModel
	private let closeCallback: () -> Void

	init(
		viewModel: TerritoryManagerSettingsViewModel,
		closeCallback: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.closeCallback = closeCallback
	}

	var body: some View {
		ScrollView {
			Text("TerritoryManager settings:")
				.foregroundColor(.primaryTitle)
				.fontWeight(.bold)
				.padding(.top, 10)

			VStack(alignment: .center) {
				PickerView(
					title: "InstallFallback type",
					titleFont: .headline,
					selection: self.$viewModel.installFallbackType,
					options: self.viewModel.installFallbackTypes,
					pickerStyle: .segmented
				)
				.padding([.leading, .trailing, .top], 10)

				if self.viewModel.installFallbackType == .retryOnError {
					SettingsFormTextFieldView(
						title: "Retry count",
						value: self.$viewModel.installFallbackRetryCount
					)
					.padding([.leading, .trailing, .top], 10)
				}
			}
			.padding(.top, 10)

			HStack(spacing: 30) {
				Button("Cancel") {
					self.closeCallback()
				}

				Button("Save") {
					self.viewModel.saveState()
					self.closeCallback()
				}
			}
			.frame(height: 44)
			.padding([.bottom, .top], 10)
		}
		.fixedSize(horizontal: false, vertical: true)
		.background(Color(.systemBackground))
		.cornerRadius(10)
		.shadow(radius: 3)
		.padding([.leading, .trailing], 20)
	}
}
