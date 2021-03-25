import SwiftUI

struct MapObjectCardView: View {

	@ObservedObject private var viewModel: MapObjectCardViewModel

	init(viewModel: MapObjectCardViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		ZStack {
			HStack(alignment: .top){
				VStack(alignment: .leading) {
					Text(self.viewModel.title)
						.font(Font.system(size: 24, weight: .regular))
						.foregroundColor(.black)
						.padding([.top, .leading], 16)
					Text(self.viewModel.description)
						.font(Font.system(size: 12, weight: .regular))
						.foregroundColor(.black)
						.padding(.top, 2)
						.padding([.bottom, .leading], 16)
				}
				Spacer()
				VStack(alignment: .trailing) {
					Button(action: {
						self.viewModel.close()
					}) {
						Image(systemName: "xmark.circle.fill")
							.resizable()
							.frame(width: 20, height: 20)
					}
					.padding([.top, .trailing], 16)
				}
				.padding(.leading, 16)
			}
		}
		.background(
			RoundedRectangle(cornerRadius: 20, style: .circular)
				.fill(Color.white)
				.shadow(color: Color.black.opacity(0.2), radius: 3)
		)
		.padding([.leading, .bottom, .trailing], 16)
	}
}
