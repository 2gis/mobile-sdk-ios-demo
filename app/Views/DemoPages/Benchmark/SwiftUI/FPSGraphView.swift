import SwiftUI

struct FPSGraphView: View {
	@ObservedObject var viewModel: BenchmarkViewModel

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				Color.gray.opacity(0.4)
				.frame(maxWidth: .infinity, maxHeight: .infinity)

				Path { path in
					let widthPerFrame = geometry.size.width / CGFloat(self.viewModel.fpsValues.count)
					for (index, fpsValue) in self.viewModel.fpsValues.enumerated() {
						let cappedFpsValue = min(fpsValue.fps, CGFloat(self.viewModel.maxRefreshRate))
						let yPosition = geometry.size.height - (CGFloat(cappedFpsValue) / CGFloat(self.viewModel.maxRefreshRate) * geometry.size.height)
						if index == 0 {
							path.move(to: CGPoint(x: CGFloat(index) * widthPerFrame, y: yPosition))
						} else {
							path.addLine(to: CGPoint(x: CGFloat(index) * widthPerFrame, y: yPosition))
						}
					}
				}
				.stroke(Color.white, lineWidth: 2)

				VStack(alignment: .leading, spacing: 4) {
					Text("FPS: \(String(format: "%.2f", lastFPS ?? 0.0))")
					Text("Avg: \(String(format: "%.2f", avgFPS))")
					Text("1%: \(String(format: "%.2f", onePercentLow))")
					Text("0.1%: \(String(format: "%.2f", zeroPointOnePercentLow))")
				}
				.font(.system(size: 14))
				.foregroundColor(.black)
				.padding(.leading, 20)
				.padding(.top, 8)
				.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
			}
		}
	}

	private var lastFPS: Double? {
		self.viewModel.fpsValues.last?.fps
	}

	private var avgFPS: Double {
		guard !self.viewModel.fpsValues.isEmpty else { return 0.0 }
		return self.viewModel.fpsValues.map{ $0.fps }.reduce(0.0, +) / Double(self.viewModel.fpsValues.count)
	}

	private var onePercentLow: Double {
		percentile(0.01)
	}

	private var zeroPointOnePercentLow: Double {
		percentile(0.001)
	}

	private func percentile(_ value: Double) -> Double {
		guard !self.viewModel.fpsValues.isEmpty else { return 0.0 }
		let sortedValues = self.viewModel.fpsValues.map{ $0.fps }.sorted()
		return sortedValues[Int(Double(sortedValues.count) * value)]
	}
}
