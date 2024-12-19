import SwiftUI

struct PolylineView: View {
	@State private var keyboardOffset: CGFloat = 0
	@ObservedObject private var viewModel: PolylineViewModel
	@Binding var show: Bool

	init(
		viewModel: PolylineViewModel,
		show: Binding<Bool>
	) {
		self.viewModel = viewModel
		self._show = show
	}

	var body: some View {
		VStack(spacing: 12.0) {
			VStack {
				Text("Points count")
				.font(.caption)
				.foregroundColor(.gray)
				TextField("", text: self.$viewModel.pointsCount)
				.frame(width: 100, height: 20, alignment: .center)
			}.background(
				RoundedRectangle(cornerRadius: 6)
				.scale(1.2)
				.fill(Color(UIColor.systemBackground))
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
				.fill(Color(UIColor.systemBackground))
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
				.fill(Color(UIColor.systemBackground))
			)
			DetailsActionView(
				action: {
					self.viewModel.polylineWidth.next()
				},
				primaryText: self.viewModel.polylineWidth.text,
				detailsText: "Width"
			)
			DetailsActionView(
				action: {
					self.viewModel.polylineColor.next()
				},
				primaryText: self.viewModel.polylineColor.text,
				detailsText: "Color"
			)
			DetailsActionView(
				action: {
					self.viewModel.polylineType.next()
				},
				primaryText: self.viewModel.polylineType.text,
				detailsText: "Type"
			)
			DetailsActionView(
				action: {
					self.viewModel.addPolyline()
				},
				primaryText: "Add polyline"
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
