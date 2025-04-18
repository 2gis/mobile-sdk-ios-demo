import SwiftUI

struct ModelView: View {
	@State private var keyboardOffset: CGFloat = 0
	@ObservedObject private var viewModel: ModelViewModel
	@Binding var show: Bool

	private var sizeValueType: String {
		self.viewModel.scaleEnabled ? "scale" : "pixel"
	}

	private var scaleEnabledStatus: String {
		self.viewModel.scaleEnabled ? "Enabled" : "Disabled"
	}

	init(
		viewModel: ModelViewModel,
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
				detailsText: "Choose model"
			)
			VStack {
				Text("ModelSize in " + self.sizeValueType)
					.font(.caption)
					.foregroundColor(.gray)
				TextField("", text: self.$viewModel.modelSize)
					.frame(width: 100, height: 20, alignment: .center)
			}.background(
				RoundedRectangle(cornerRadius: 6)
				.scale(1.2)
				.fill(Color.white)
			)
			DetailsActionView(
				action: {
					self.viewModel.scaleEnabled = !self.viewModel.scaleEnabled
				},
				primaryText: self.scaleEnabledStatus,
				detailsText: "Scale"
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
					self.viewModel.addModel()
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


