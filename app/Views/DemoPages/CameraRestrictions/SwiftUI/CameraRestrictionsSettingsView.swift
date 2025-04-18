import SwiftUI

struct CameraRestrictionsSettingsView: View {
	private enum Constants {
		static let textFieldFrameWidth: CGFloat = 80
	}

	@Binding var isPresented: Bool
	@Binding var minZoom: Float
	@Binding var maxZoom: Float
	@Binding var maxTiltRelationPoints: [RelationPoint]
	@Binding var zoomToTiltRelationPoints: [RelationPoint]

	var onApplySettings: () -> Void

	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Zoom Restrictions")) {
					HStack {
						Text("Min zoom:")
						Spacer()
						TextField("Min zoom", value: $minZoom, formatter: .zoomFormatter)
						.textFieldStyle(.roundedBorder)
						.keyboardType(.numbersAndPunctuation)
						.frame(width: Constants.textFieldFrameWidth)
					}
					HStack {
						Text("Max Zoom:")
						Spacer()
						TextField("Max zoom", value: $maxZoom, formatter: .zoomFormatter)
						.textFieldStyle(.roundedBorder)
						.keyboardType(.numbersAndPunctuation)
						.frame(width: Constants.textFieldFrameWidth)
					}
				}
				if #available(iOS 15, *) {
					RelationPointsView(
						relationPoints: self.$maxTiltRelationPoints,
						sectionName: "Max Tilt Relation Points",
						textFieldFrameWidth: Constants.textFieldFrameWidth
					)
					RelationPointsView(
						relationPoints: self.$zoomToTiltRelationPoints,
						sectionName: "Style Zoom To Tilt Relation Points",
						textFieldFrameWidth: Constants.textFieldFrameWidth
					)
				}

				Button(action: {
					self.isPresented = false
					self.onApplySettings()
				}) {
					Text("Apply Settings")
					.foregroundColor(.white)
					.padding()
					.frame(maxWidth: .infinity)
				}
				.listRowBackground(Color.clear)
				.background(Color.green)
				.cornerRadius(10)
				.padding()
			}
		}
		.background(Color(UIColor.secondarySystemFill))
	}
}
