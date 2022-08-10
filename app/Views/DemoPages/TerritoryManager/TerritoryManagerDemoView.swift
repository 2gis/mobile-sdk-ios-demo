import SwiftUI

struct TerritoryManagerDemoView: View {
	@ObservedObject private var viewModel: TerritoryManagerDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: TerritoryManagerDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		VStack {
			if #available(iOS 15.0, *) {
				self.makeSearchField()
				.submitLabel(.search)
				.padding([.top, .trailing, .leading])
			} else {
				self.makeSearchField()
				.padding()
			}
			List(self.viewModel.territories) { viewModel in
				TerritoryView(viewModel: viewModel)
			}
		}
		.navigationBarItems(trailing: self.checkForUpdatesButton())
	}

	private func makeSearchField() -> some View {
		TextField("Поиск", text: self.$viewModel.searchString)
		.multilineTextAlignment(.center)
	}

	private func checkForUpdatesButton() -> some View {
		Button {
			self.viewModel.checkForUpdates()
		} label: {
			Image(systemName: "arrow.triangle.2.circlepath")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(minWidth: 25, minHeight: 25)
		}
	}
}
