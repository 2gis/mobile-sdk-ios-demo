import SwiftUI

struct PolygonView: View {
	@State private var keyboardOffset: CGFloat = 0
	@ObservedObject private var viewModel: PolygonViewModel
	@Binding var show: Bool

	init(
		viewModel: PolygonViewModel,
		show: Binding<Bool>
	) {
		self.viewModel = viewModel
		self._show = show
	}

	var body: some View {
		VStack(spacing: 12.0) {
			VStack {
				Text("Contour size")
				.font(.caption)
				.foregroundColor(.gray)
				TextField("", text: self.$viewModel.contourSize)
				.frame(width: 100, height: 20, alignment: .center)
			}.background(
				RoundedRectangle(cornerRadius: 6)
				.scale(1.2)
				.fill(Color.white)
			)
			VStack {
				Text("Contours count")
				.font(.caption)
				.foregroundColor(.gray)
				TextField("", text: self.$viewModel.contoursCount)
				.frame(width: 100, height: 20, alignment: .center)
			}.background(
				RoundedRectangle(cornerRadius: 6)
				.scale(1.2)
				.fill(Color.white)
			)
			DetailsActionView(
				action: {
					self.viewModel.polygonColor.next()
				},
				primaryText: self.viewModel.polygonColor.text,
				detailsText: "Color"
			)
			DetailsActionView(
				action: {
					self.viewModel.strokeWidth.next()
				},
				primaryText: self.viewModel.strokeWidth.text,
				detailsText: "Stroke width"
			)
			DetailsActionView(
				action: {
					self.viewModel.strokeColor.next()
				},
				primaryText: self.viewModel.strokeColor.text,
				detailsText: "Stroke color"
			)
			DetailsActionView(
				action: {
					self.viewModel.addPolygon()
				},
				primaryText: "Add polygon"
			)
			DetailsActionView(
				action: {
					self.show = false
				},
				primaryText: "Close"
			)
		}
		.alert(isPresented: self.$viewModel.isErrorAlertShown) {
			Alert(title: Text(self.viewModel.errorMessage ?? ""))
		}
		.followKeyboard(self.$keyboardOffset)
	}
}
