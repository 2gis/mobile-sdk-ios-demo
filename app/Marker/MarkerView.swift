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
			}, primaryText: self.viewModel.type.text, detailsText: "Выберите маркер")
			DetailsActionView(action: {
				self.viewModel.size.next()
			}, primaryText: self.viewModel.size.text, detailsText: "Установите размер")
			VStack {
				Text("Добавьте текст").font(.caption).foregroundColor(.gray)
				TextField("", text: self.$text)
					.frame(width: 100, height: 20, alignment: .center)
			}.background(RoundedRectangle(cornerRadius: 6).scale(1.2).fill(Color.white))
			DetailsActionView(action: {
				self.viewModel.addMarkers(text: self.text)
			}, primaryText: "Установить")
			if self.viewModel.hasMarkers {
				DetailsActionView(action: {
					self.viewModel.removeAll()
				}, primaryText: "Удалить все")
			}
			DetailsActionView(action: {
				self.show = false
			}, primaryText: "Закрыть")
		}
		.padding([.trailing], 40.0)
		.padding([.bottom], 60.0)
	}
}


