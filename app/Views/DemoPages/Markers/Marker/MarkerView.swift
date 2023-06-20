import SwiftUI

struct MarkerView: View {
	@ObservedObject private var viewModel: MarkerViewModel
	@Binding var show: Bool
	@State private var text: String = ""

	init(
		viewModel: MarkerViewModel,
		show: Binding<Bool>
	) {
		self.viewModel = viewModel
		self._show = show
	}

	var body: some View {
		VStack(spacing: 12.0) {
			DetailsActionView(action: {
				self.viewModel.type.next()
			}, primaryText: self.viewModel.type.text, detailsText: "Choose marker")
			DetailsActionView(action: {
				self.viewModel.size.next()
			}, primaryText: self.viewModel.size.text, detailsText: "Set size")
			VStack {
				Text("Add text")
				.font(.caption)
				.foregroundColor(.gray)
				TextField("", text: self.$text)
				.frame(width: 100, height: 20, alignment: .center)
			}.background(
				RoundedRectangle(cornerRadius: 6)
				.scale(1.2)
				.fill(Color.white)
			)
			DetailsActionView(action: {
				self.viewModel.addMarker(text: self.text)
			}, primaryText: "Set")
			if self.viewModel.hasMarkers {
				DetailsActionView(action: {
					self.viewModel.removeAll()
				}, primaryText: "Remove all")
			}
			DetailsActionView(action: {
				self.show = false
			}, primaryText: "Close")
		}
		.padding([.trailing], 40.0)
		.padding([.bottom], 60.0)
	}
}
