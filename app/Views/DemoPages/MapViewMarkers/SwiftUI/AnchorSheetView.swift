import SwiftUI

struct AnchorSheetView: View {
	private enum Constants {
		static let textFieldFrameWidth: CGFloat = 80
	}

	@Binding var isPresented: Bool
	@Binding var anchor: AnchorPoint
	@Binding var offsetX: CGFloat
	@Binding var offsetY: CGFloat

	var body: some View {
		VStack {
			HStack {
				Spacer()
				Button(action: {
					self.isPresented = false
				}) {
					Text("Close")
						.padding()
						.foregroundColor(.blue)
				}
			}

			Spacer()

			HStack {
				Text("Offset X:")
				Spacer()
				TextField("Offset X", value: self.$offsetX, formatter: .offsetFormatter)
					.textFieldStyle(.roundedBorder)
					.keyboardType(.numberPad)
					.frame(width: Constants.textFieldFrameWidth)
			}

			HStack {
				Text("Offset Y:")
				Spacer()
				TextField("Offset Y", value: self.$offsetY, formatter: .offsetFormatter)
					.textFieldStyle(.roundedBorder)
					.keyboardType(.numberPad)
					.frame(width: Constants.textFieldFrameWidth)
			}

			Text("Choose anchor")
				.font(.headline)
				.padding()

			VStack(spacing: 20) {
				HStack(spacing: 20) {
					anchorButton(title: "↖︎", anchorPoint: .topLeading)
					anchorButton(title: "↑", anchorPoint: .top)
					anchorButton(title: "↗︎", anchorPoint: .topTrailing)
				}
				HStack(spacing: 20) {
					anchorButton(title: "←", anchorPoint: .leading)
					anchorButton(title: "●", anchorPoint: .center)
					anchorButton(title: "→", anchorPoint: .trailing)
				}
				HStack(spacing: 20) {
					anchorButton(title: "↙︎", anchorPoint: .bottomLeading)
					anchorButton(title: "↓", anchorPoint: .bottom)
					anchorButton(title: "↘︎", anchorPoint: .bottomTrailing)
				}
			}
			.padding()
		}
		.padding()
	}

	private func anchorButton(title: String, anchorPoint: AnchorPoint) -> some View {
		Button(action: {
			self.anchor = anchorPoint
		}) {
			Text(title)
				.font(.largeTitle)
				.frame(width: 60, height: 60)
				.background(self.anchor == anchorPoint ? Color.accentColor : Color(UIColor.secondarySystemBackground))
				.cornerRadius(10)
				.foregroundColor(.black)
		}
	}
}

private extension View {
	@ViewBuilder
	func ifAvailableIOS15<Content: View>(_ transform: (Self) -> Content) -> some View {
		if #available(iOS 15, *) {
			transform(self)
		} else {
			self
		}
	}
}
