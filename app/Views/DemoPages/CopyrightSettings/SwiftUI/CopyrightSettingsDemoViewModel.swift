import SwiftUI
import DGis

final class CopyrightSettingsDemoViewModel: ObservableObject {
	@Published var alignment: CopyrightAlignment = .bottomLeft
	@Published var insets: EdgeInsets = .init()
	@Published var showsAPIVersion: Bool = true
	@Published var showSettings: Bool = false

	init() {}
}
