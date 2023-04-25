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
			self.viewFactory.makeMapViewWithZoomControl(alignment: .bottomLeft)
			.overlay(self.visibleAreaStateIndicator(), alignment: .bottom)
			if self.viewModel.isTrackingActive {
				self.stopTrackingButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
			} else {
				self.startTrackingButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
			}
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
			.frame(width: 40, height: 40, alignment: .center)
			.foregroundColor(.white)
			.shadow(color: .gray, radius: 1)
		})
		.padding(.bottom, 40)
		.padding(.trailing, 20)
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
