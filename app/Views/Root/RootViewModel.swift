import Combine
import DGis

final class RootViewModel: ObservableObject {
	let demoPages: [DemoPage]
	let settingsViewModel: SettingsViewModel

	@Published var showsSettings: Bool = false
	@Published var mapDataSourceId: String
	@Published var isErrorAlertShown: Bool = false
	var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	init(
		demoPages: [DemoPage],
		settingsService: ISettingsService,
		settingsViewModel: SettingsViewModel
	) {
		self.demoPages = demoPages
		self.settingsViewModel = settingsViewModel
		self.mapDataSourceId = settingsService.mapDataSource.rawValue

		self.settingsViewModel.mapDataSourceChangedCallback = {
			[weak self] source in
			self?.mapDataSourceId = source.rawValue
		}
	}
}
