import Combine
import DGis
import SwiftUI

final class MapSnapshotDemoViewModel: ObservableObject {
	private let mapFactoryProvider: () throws -> DGis.IMapFactory

	init(mapFactoryProvider: @escaping () throws -> DGis.IMapFactory) {
		self.mapFactoryProvider = mapFactoryProvider
	}

	@MainActor
	func makeMapSnapshotView() -> any View {
		MapSnapshotView(mapFactory: try! self.mapFactoryProvider())
	}
}
