import SwiftUI
import Combine
import PlatformMapSDK

final class RootViewModel: ObservableObject {
	let demoPages: [DemoPage]

	init(demoPages: [DemoPage]) {
		self.demoPages = demoPages
	}
}
