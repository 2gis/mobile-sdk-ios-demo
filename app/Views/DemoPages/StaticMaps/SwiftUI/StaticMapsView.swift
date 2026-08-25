import DGis
import SwiftUI

struct StaticMapsView: View {
	@Environment(\.colorScheme) var colorScheme
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
					self.mapFactory.mapView
						.frame(height: Constants.snapshotHeight)
						.opacity(0)
				}
			}
		}
		.onAppear(perform: self.viewModel.makeMapSnapshots)
		.onChange(of: self.colorScheme, perform: { _ in self.viewModel.makeMapSnapshots() })
	}
}
