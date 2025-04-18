import SwiftUI
import Combine

final class MapThemeDemoViewModel: ObservableObject {
	@Published var showActionSheet = false
	@Published var currentTheme: MapTheme = .default
	let availableThemes: [MapTheme] = MapTheme.allCases

	init() {}
}


