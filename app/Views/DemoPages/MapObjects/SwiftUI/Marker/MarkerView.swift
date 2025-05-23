import SwiftUI

struct MarkerView: View {
	@State private var keyboardOffset: CGFloat = 0
	@ObservedObject private var viewModel: MarkerViewModel
	@Binding var show: Bool

	init(
		viewModel: MarkerViewModel,
		show: Binding<Bool>
	) {
		self.viewModel = viewModel
		self._show = show
	}

	var body: some View {
		VStack(spacing: 12.0) {
			DetailsActionView(
				action: {
					self.viewModel.type.next()
				},
				primaryText: self.viewModel.type.text,
				detailsText: "Choose marker"
			)
			DetailsActionView(
				action: {
					self.viewModel.size.next()
				},
				primaryText: self.viewModel.size.text,
				detailsText: "Size"
			)
			DetailsActionView(
				action: {
					self.viewModel.animationMode.next()
				},
				primaryText: self.viewModel.animationMode.text,
				detailsText: "Animation mode"
			)
			VStack {
				Text("Add text")
				.font(.caption)
				.foregroundColor(.gray)
				TextField("", text: self.$viewModel.markerText)
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
					self.viewModel.addMarker()
				},
				primaryText: "Add marker"
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


