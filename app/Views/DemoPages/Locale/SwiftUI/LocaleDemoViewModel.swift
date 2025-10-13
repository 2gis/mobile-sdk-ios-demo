import Combine
import DGis
import Foundation
import SwiftUI

final class LocaleDemoViewModel: ObservableObject, @unchecked Sendable {
	var currentLanguage: Language {
		self.settingsService.language
	}

	@Published var currentLocales: String = ""
	@Published var systemLocales: String = ""

	private let map: Map
	private let localeManager: LocaleManager
	private let settingsService: ISettingsService
	private var localeCancellable: ICancellable = NoopCancellable()

	init(
		map: Map,
		settingsService: ISettingsService,
		localeManager: LocaleManager

	) {
		self.map = map
		self.localeManager = localeManager
		self.settingsService = settingsService
		self.switchLanguage(language: self.currentLanguage)

		self.localeCancellable = self.localeManager.localesChannel.sinkOnMainThread { [weak self] locales in
			Task { @MainActor [weak self] in
				self?.currentLocales = locales.map { $0.toLocalePosix() }.joined(separator: ",")
			}
		}
		self.systemLocales = self.localeManager.systemLocales.map { $0.toLocalePosix() }.joined(separator: ",")
	}

	func switchToNextLocale() {
		self.switchLanguage(language: self.settingsService.language.next())
	}

	private func switchLanguage(language: Language) {
		self.settingsService.language = language
		let locales = language.locale.map { [$0] }
		self.localeManager.overrideLocales(locales: locales ?? [])
	}
}
