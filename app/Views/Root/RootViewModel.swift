import Combine
import DGis

final class RootViewModel: ObservableObject {
	let demoPages: [DemoPage]
	let settingsViewModel: SettingsViewModel

	@Published var showsSettings: Bool = false
	@Published var mapDataSourceId: String

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
