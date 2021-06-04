import SwiftUI
import Combine
import PlatformSDK

final class RootViewModel: ObservableObject {
	let demoPages: [DemoPage]

	init(demoPages: [DemoPage]) {
		self.demoPages = demoPages
	}
}
