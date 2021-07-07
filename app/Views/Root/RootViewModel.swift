import SwiftUI
import Combine
import DGis

final class RootViewModel: ObservableObject {
	let demoPages: [DemoPage]

	init(demoPages: [DemoPage]) {
		self.demoPages = demoPages
	}
}
