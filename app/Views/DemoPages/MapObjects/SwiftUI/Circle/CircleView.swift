import SwiftUI

struct CircleView: View {
	@State private var keyboardOffset: CGFloat = 0
	@ObservedObject private var viewModel: CircleViewModel
	@Binding var show: Bool

	init(
		viewModel: CircleViewModel,
		show: Binding<Bool>
	) {
		self.viewModel = viewModel
		self._show = show
	}

	var body: some View {
		VStack(spacing: 12.0) {
			VStack {
				Text("Radius")
				.font(.caption)
				.foregroundColor(.gray)
				TextField("", text: self.$viewModel.circleRadius)
				.frame(width: 100, height: 20, alignment: .center)
			}.background(
				RoundedRectangle(cornerRadius: 6)
				.scale(1.2)
				.fill(Color.white)
			)
			VStack {
				Text("zIndex")
				.font(.caption)
				.foregroundColor(.gray)
				TextField("", text: self.$viewModel.zIndex)
				.frame(width: 100, height: 20, alignment: .center)
			}.background(
				RoundedRectangle(cornerRadius: 6)
				.scale(1.2)
				.fill(Color.white)
			)
			VStack {
				Text("UserData")
				.font(.caption)
				.foregroundColor(.gray)
				TextField("", text: self.$viewModel.userData)
				.frame(width: 100, height: 20, alignment: .center)
			}.background(
				RoundedRectangle(cornerRadius: 6)
				.scale(1.2)
				.fill(Color.white)
			)
			DetailsActionView(
				action: {
					self.viewModel.circleColor.next()
				},
				primaryText: self.viewModel.circleColor.text,
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
					self.viewModel.strokeType.next()
				},
				primaryText: self.viewModel.strokeType.text,
				detailsText: "Stroke type"
			)
			DetailsActionView(
				action: {
					self.viewModel.addCircle()
				},
				primaryText: "Add circle"
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
