import SwiftUI
import DGis

final class MapSnapshotDemoViewModel: ObservableObject {
	private let sdk: DGis.Container

	init(sdk: DGis.Container) {
		self.sdk = sdk
	}

	func makeMapSnapshotView() -> any View {
		MapSnapshotView(mapFactory: try! self.sdk.makeMapFactory(options: .default))
	}
}
