import SwiftUI

struct TerritoryManagerListView: View {
	private enum Constants {
		static let backgroundPadding: CGFloat = 4
		static let cornerRadius: CGFloat = 12
		static let font: Font = .system(size: 14)
		static let currentTerritoryFont: Font = .system(size: 14)
		static let textColor: Color = .white
		static let accentColor: Color = .init("colors/dgis_dark_green")
	}

	@ObservedObject private var viewModel: TerritoryManagerDemoViewModel

	init(viewModel: TerritoryManagerDemoViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		VStack {
			HStack {
				self.makeSearchField()
					.submitLabel(.search)
					.padding([.top, .trailing, .leading])
				self.detailsSettingsButton()
					.padding([.top, .trailing, .leading])
			}
			List {
				if !self.myTerritories.isEmpty {
					Section(header: Text("My territories")) {
						ForEach(self.myTerritories) { viewModel in
							if self.isCurrentLocation(territory: viewModel) {
								VStack(alignment: .leading) {
									TerritoryView(viewModel: viewModel)
									Text("• You are here")
										.font(Constants.font)
										.foregroundColor(Constants.textColor)
										.padding(Constants.backgroundPadding)
										.background(
											RoundedRectangle(cornerRadius: Constants.cornerRadius)
												.foregroundColor(Constants.accentColor)
										)
								}
							} else {
								TerritoryView(viewModel: viewModel)
							}
						}
					}
				}
				if !self.availableTerritories.isEmpty {
					Section(header: Text("Available territories")) {
						ForEach(self.availableTerritories) { viewModel in
							TerritoryView(viewModel: viewModel)
						}
					}
				}
			}
			.listStyle(.grouped)
		}
		.sheet(isPresented: self.$viewModel.showDetailsSettings) {
			TerritoryManagerSettingsView(viewModel: self.viewModel.territoryManagerSettingsViewModel) { [weak viewModel = self.viewModel] in
				viewModel?.showDetailsSettings = false
			}
		}
	}

	private func makeSearchField() -> some View {
		TextField("Filter", text: self.$viewModel.searchString)
			.multilineTextAlignment(.center)
	}

	private var myTerritoriesFilter: (TerritoryViewModel) -> Bool {
		{ viewModel in
			switch viewModel.status {
			case .preinstalled, .installed, .hasUpdate:
				true
			default:
				self.isCurrentLocation(territory: viewModel)
			}
		}
	}

	private var availableTerritoriesFilter: (TerritoryViewModel) -> Bool {
		{ viewModel in
			!self.myTerritoriesFilter(viewModel)
		}
	}

	private func isCurrentLocation(territory: TerritoryViewModel) -> Bool {
		self.viewModel.currentLocationTerritories.map(\.package).contains(territory.package)
	}

	private var myTerritories: [TerritoryViewModel] {
		self.viewModel.packages.filter(self.myTerritoriesFilter)
	}

	private var availableTerritories: [TerritoryViewModel] {
		self.viewModel.packages.filter(self.availableTerritoriesFilter)
	}

	private func detailsSettingsButton() -> some View {
		Button {
			self.viewModel.showDetailsSettings = true
		} label: {
			Image(systemName: "gear")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 30)
		}
	}
}
