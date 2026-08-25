import DGis
import SwiftUI

struct SearchResultView: View {
	private enum Constants {
		enum Paddings {
			static let itemsPadding: CGFloat = 15
			static let stackTopOffset: CGFloat = 4
			static let itemsSpacing: CGFloat = 16
			static let routeButtonPadding: CGFloat = 8
		}

		enum Colors {
			static let secondaryBackground: SwiftUI.Color = .init("colors/secondary_background")
			static let background: SwiftUI.Color = .init("colors/background")
			static let routeButtonLabel: SwiftUI.Color = .white
			static let routeButtonBackground: SwiftUI.Color = .init("colors/dgis_green")
		}

		static let itemsCornerRadius: CGFloat = 12
		static let routeButtonCornerRadius: CGFloat = 8

		static let buildingCodes: [PurposeCode] = [
			.init(value: 2), // Administrative building
			.init(value: 42), // Residential building
			.init(value: 70), // Private house
			.init(value: 520), // Villa
		]
	}

	@ObservedObject var viewModel: SearchResultViewModel
	let directoryViewsFactory: IDirectoryViewsFactory
	let navigation: NavigationService = .init()

	var body: some View {
		ScrollView {
			LazyVStack(spacing: Constants.Paddings.itemsSpacing) {
				ForEach(self.viewModel.objects) { object in
					VStack(alignment: .leading) {
						self.directoryViewsFactory.makeSearchResultItemView(
							object: object,
							onTap: { object in
								self.navigation.push(
									DirectoryObjectView(
										viewModel: .init(
											object: object,
											lastLocation: self.viewModel.lastPosition
										)
									)
								)
							},
							lastLocation: self.viewModel.lastPosition
						)
						self.makeRouteButton(object: object)
					}
					.padding(Constants.Paddings.itemsPadding)
					.background(Constants.Colors.background)
					.cornerRadius(Constants.itemsCornerRadius)
				}
				.padding(.horizontal)
				// Needed to implement "infinite scrolling" of search results
				Color.clear
					.frame(height: 1)
					.onAppear {
						self.viewModel.loadNextPage()
					}
			}
			.padding(.top, Constants.Paddings.stackTopOffset)
			.background(Constants.Colors.secondaryBackground)
		}
	}

	@ViewBuilder
	private func makeRouteButton(object: DirectoryObject) -> some View {
		if let purposeCode = object.buildingInfo?.purposeCode,
		   Constants.buildingCodes.contains(purposeCode),
		   let point = object.markerPosition
		{
			Button(action: {
				self.navigation.present(
					VStack {
						Text(String(
							format: "Route to point: %.6f, %.6f",
							point.latitude.value,
							point.longitude.value
						))
					}
				)
			}) {
				HStack {
					Image("svg/route")
						.renderingMode(.template)
					Text("Route")
				}
				.foregroundColor(Constants.Colors.routeButtonLabel)
			}
			.padding(Constants.Paddings.routeButtonPadding)
			.background(Constants.Colors.routeButtonBackground)
			.cornerRadius(Constants.routeButtonCornerRadius)
		}
	}
}
