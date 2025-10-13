import Combine
import DGis
import SwiftUI

final class RootViewModel: ObservableObject {
	@Published var demos: [DemoPage]
	@Published var filteredDemos: [DemoPage]
	@Published var filterText: String = ""
	@Published var isFiltering: Bool = false
	@Published var showsSettings: Bool = false
	@Published var isErrorAlertShown: Bool = false

	let settingsViewModel: SettingsViewModel

	var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	init(
		demos: [DemoPage],
		settingsService _: ISettingsService,
		settingsViewModel: SettingsViewModel
	) {
		self.demos = demos
		self.filteredDemos = demos
		self.settingsViewModel = settingsViewModel
	}

	func filterDemos() {
		if self.filterText.isEmpty {
			self.filteredDemos = self.demos
		} else {
			self.filteredDemos = self.demos.filter { $0.name.lowercased().contains(self.filterText.lowercased()) }
		}
	}

	func demos(for category: DemoCategory) -> [DemoPage] {
		self.filteredDemos.filter { $0.category == category }
	}
}
