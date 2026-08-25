import SwiftUI

struct CalcPositionSettingsView: View {
	@Binding var isPresented: Bool
	@Binding var padding: PaddingRect
	@Binding var tilt: Float
	@Binding var bearing: Double
	@Binding var calcPositionWay: CalcPositionWays

	var onApplySettings: () -> Void

	private enum Constants {
		static let textFieldFrameWidth: CGFloat = 80
		static let screenScaleValue: CGFloat = 3
	}

	private let verticalFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .none
		formatter.allowsFloats = false
		formatter.minimum = 0
		formatter.maximum = (UIScreen.main.bounds.size.height * Constants.screenScaleValue) as NSNumber
		return formatter
	}()

	private let horizontalFormatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .none
		formatter.allowsFloats = false
		formatter.minimum = 0
		formatter.maximum = (UIScreen.main.bounds.size.width * Constants.screenScaleValue) as NSNumber
		return formatter
	}()

	var body: some View {
		VStack(alignment: .leading, spacing: 5) {
			HStack {
				Text("Top Padding:")
				Spacer()
				if self.padding.top != 0 {
					self.clearButton(for: self.$padding.top)
				}
				TextField("Enter a value", value: self.$padding.top, formatter: self.verticalFormatter)
					.textFieldStyle(.roundedBorder)
					.keyboardType(.numbersAndPunctuation)
					.frame(width: Constants.textFieldFrameWidth)
			}
			HStack {
				Text("Bottom Padding:")
				Spacer()
				if self.padding.bottom != 0 {
					self.clearButton(for: self.$padding.bottom)
				}
				TextField("Enter a value", value: self.$padding.bottom, formatter: self.verticalFormatter)
					.textFieldStyle(.roundedBorder)
					.keyboardType(.numbersAndPunctuation)
					.frame(width: Constants.textFieldFrameWidth)
			}
			HStack {
				Text("Left Padding:")
				Spacer()
				if self.padding.left != 0 {
					self.clearButton(for: self.$padding.left)
				}
				TextField("Enter a value", value: self.$padding.left, formatter: self.horizontalFormatter)
					.textFieldStyle(.roundedBorder)
					.keyboardType(.numbersAndPunctuation)
					.frame(width: Constants.textFieldFrameWidth)
			}
			HStack {
				Text("Right Padding:")
				Spacer()
				if self.padding.right != 0 {
					self.clearButton(for: self.$padding.right)
				}
				TextField("Enter a value", value: self.$padding.right, formatter: self.horizontalFormatter)
					.textFieldStyle(.roundedBorder)
					.keyboardType(.numbersAndPunctuation)
					.frame(width: Constants.textFieldFrameWidth)
			}
			HStack {
				Text("Tilt:")
				Spacer()
				if self.tilt != 0 {
					self.clearButton(for: self.$tilt)
				}
				TextField("Enter a value", value: self.$tilt, formatter: .tiltFormatter)
					.textFieldStyle(.roundedBorder)
					.keyboardType(.numbersAndPunctuation)
					.frame(width: Constants.textFieldFrameWidth)
			}
			HStack {
				Text("Bearing:")
				Spacer()
				if self.bearing != 0 {
					self.clearButton(for: self.$bearing)
				}
				TextField("Enter a value", value: self.$bearing, formatter: .bearingFormatter)
					.textFieldStyle(.roundedBorder)
					.keyboardType(.numbersAndPunctuation)
					.frame(width: Constants.textFieldFrameWidth)
			}
			HStack {
				Text("Use:")
				Spacer()
				Picker(
					"Choose way to use calcPosition",
					selection: self.$calcPositionWay
				) {
					ForEach(CalcPositionWays.allCases) { way in
						Text(way.displayName).tag(way)
					}
				}
			}
			Button(action: {
				self.onApplySettings()
				self.isPresented = false
			}
			) {
				Text("Calculate camera position")
					.foregroundColor(.white)
					.padding()
					.frame(maxWidth: .infinity)
			}
			.background(Color.green)
			.cornerRadius(10)
			.padding()
		}
		.padding()
		.background(Color(UIColor.systemBackground).opacity(0.9))
		.cornerRadius(10)
		.padding()
	}

	private func clearButton(for binding: Binding<CGFloat>) -> some View {
		Button(action: {
			binding.wrappedValue = 0
		}) {
			Image(systemName: "multiply.circle.fill")
				.foregroundColor(.gray)
		}
	}

	private func clearButton(for binding: Binding<Float>) -> some View {
		Button(action: {
			binding.wrappedValue = 0
		}) {
			Image(systemName: "multiply.circle.fill")
				.foregroundColor(.gray)
		}
	}

	private func clearButton(for binding: Binding<Double>) -> some View {
		Button(action: {
			binding.wrappedValue = 0
		}) {
			Image(systemName: "multiply.circle.fill")
				.foregroundColor(.gray)
		}
	}
}
