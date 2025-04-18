import SwiftUI
import DGis

struct StaticMapsView: View {
	@ObservedObject private var viewModel: StaticMapsViewModel
	private let mapFactory: IMapFactory

	private enum Constants {
		static let snapshotHeight: CGFloat = 250
	}

	init(
		viewModel: StaticMapsViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ScrollView {
			VStack {
				ForEach(self.viewModel.snapshotData, id: \.snapshot) { data in
					SnapshotView(
						snapshot: data.snapshot,
						pointA: data.startPoint,
						pointB: data.endPoint
					)
					.padding(5)
				}
				if self.viewModel.needMapViewToExist {
					self.mapFactory.mapViewOverlay
					.frame(height: Constants.snapshotHeight)
					.opacity(0)
				}
			}
		}
		.onAppear(perform: self.viewModel.makeMapSnapshots)
		.modifier(
			OnChangeModifier(
				action: {
					self.viewModel.makeMapSnapshots()
				}
			)
		)
	}
}

private struct OnChangeModifier: ViewModifier {
	@Environment(\.colorScheme) var colorScheme
	let action: () -> Void

	func body(content: Content) -> some View {
		// Checking if it is available .onChange
		if #available(iOS 14.0, *) {
			content.onChange(of: colorScheme, perform: { _ in action() })
		} else {
			content
		}
	}
}
