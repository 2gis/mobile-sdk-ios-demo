import SwiftUI

struct VisibleAreaDetectionDemoView: View {
	@ObservedObject private var viewModel: VisibleAreaDetectionDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: VisibleAreaDetectionDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			Group {
				self.viewFactory.makeMapView(alignment: .bottomLeft)
				HStack {
					Spacer()
					VStack {
						Spacer()
						self.viewFactory.makeZoomControl()
						.frame(width: 48, height: 102)
						.padding(.bottom, 10)
						self.viewFactory.makeCurrentLocationControl()
						.frame(width: 48, height: 48)
						Spacer()
					}
					.padding(.trailing, 10)
				}
			}
			.overlay(self.visibleAreaStateIndicator(), alignment: .bottom)
			if self.viewModel.isTrackingActive {
				self.stopTrackingButton()
				.padding()
			} else {
				VStack(alignment: .trailing) {
					self.startTrackingButton()
					.padding(.bottom, 10)
					VStack {
						Text("Rect expansion ration")
						.fontWeight(.light)
						.padding([.top, .leading, .trailing], 10)
						HStack {
							Text(String(format: "%.1f", self.viewModel.rectExpansionRatio))
							Slider(
								value: self.$viewModel.rectExpansionRatio,
								in: self.viewModel.minRectExpansionRatio...self.viewModel.maxRectExpansionRatio
							)
							.frame(maxWidth: 200)
						}
						.padding(.bottom, 10)
					}
					.background(
						RoundedRectangle(cornerRadius: 5)
						.fill(Color.white)
					)
				}
				.padding([.bottom, .trailing])
			}
		}
		.alert(isPresented: self.$viewModel.isErrorAlertShown) {
			Alert(title: Text(self.viewModel.errorMessage ?? ""))
		}
		.edgesIgnoringSafeArea([.leading, .bottom, .trailing])
	}

	private func visibleAreaStateIndicator() -> some View {
		HStack {
			if let state = self.viewModel.visibleAreaIndicatorState {
				Circle()
				.foregroundColor(.from(state))
				.frame(width: 24, height: 24)
				.shadow(color: .gray, radius: 0.2, x: 1, y: 1)
				Text(state == .inside ? "Inside" : "Outside")
			}
		}
		.padding()
	}

	private func startTrackingButton() -> some View {
		self.makeActionButton(imageSystemName: "square.dashed.inset.fill") {
			self.viewModel.detectExtendedVisibleRectChange()
		}
	}

	private func stopTrackingButton() -> some View {
		self.makeActionButton(imageSystemName: "xmark.circle.fill") {
			self.viewModel.stopVisibleRectTracking()
		}
	}

	private func makeActionButton(
		imageSystemName: String,
		_ action: @escaping () -> Void
	) -> some View {
		Button(action: action,
			   label: {
			Image(systemName: imageSystemName)
			.resizable()
			.frame(width: 44, height: 44, alignment: .center)
			.foregroundColor(.white)
			.shadow(color: .gray, radius: 1)
		})
	}
}

private extension Color {
	static func from(_ state: VisibleAreaDetectionDemoViewModel.VisibleAreaState) -> Color {
		let color: Color
		switch state {
			case .inside: color = .green
			case .outside: color = .red
		}
		return color
	}
}
