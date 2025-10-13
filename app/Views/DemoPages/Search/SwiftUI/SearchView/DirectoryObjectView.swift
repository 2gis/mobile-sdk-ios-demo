import SwiftUI

struct DirectoryObjectView: View {
	let viewModel: DirectoryObjectViewModel

	var body: some View {
		Divider()
		ScrollView(.vertical) {
			VStack(alignment: .leading) {
				Group {
					Text(self.viewModel.title)
						.font(.headline)
					Text(self.viewModel.subtitle)
						.font(.subheadline)
					if !self.viewModel.description.isEmpty {
						Text(self.viewModel.description)
							.font(.subheadline)
					}
					Text("id: \(self.viewModel.objectId)")
						.font(.subheadline)
					HStack {
						if let reviews = self.viewModel.reviews {
							Text(String(format: "%.1f", reviews.rating))
								.font(.subheadline)
								.bold()
								.foregroundColor(.primary)
							Text("\(reviews.count) reviews")
								.font(.subheadline)
								.foregroundColor(.secondary)
						} else {
							Text("No reviews")
								.font(.subheadline)
								.foregroundColor(.secondary)
						}
						Spacer()
						if let distanceText = self.viewModel.distanceToObject?.description {
							Text(distanceText)
								.font(.subheadline)
								.bold()
								.foregroundColor(.secondary)
						}
					}
				}
				Group {
					self.viewModel.address.map(FormattedAddressView.init)?
						.padding([.top, .bottom], 8)
						.foregroundColor(.gray)
					if let position = self.viewModel.markerPosition?.point {
						Text(String(format: "Latitude: %.6f, Longitude: %.6f", position.latitude.value, position.longitude.value))
							.font(.subheadline)
							.foregroundColor(.gray)
					}
				}
				Group {
					SpoilerView(
						title: "Opening hours",
						content: {
							Text(self.viewModel.openingHours)
								.font(.subheadline)
						}
					)
					if let chargingStation = self.viewModel.chargingStation {
						ChargingStationInfoView(station: chargingStation)
					}
					SpoilerView(
						title: "Attributes",
						content: {
							Text(self.viewModel.attributes)
								.font(.subheadline)
						}
					)
					SpoilerView(
						title: "Context Attributes",
						content: {
							Text(self.viewModel.contextAttributes)
								.font(.subheadline)
						}
					)
					SpoilerView(
						title: "Trade license",
						content: {
							Text(self.viewModel.tradeLicense)
								.font(.subheadline)
						}
					)
					SpoilerView(
						title: "Building info",
						content: {
							Text(self.viewModel.buildingInfo)
								.font(.subheadline)
						}
					)
				}.padding([.leading, .trailing], 2)
			}
		}
		.padding()
	}
}
