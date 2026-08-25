import Combine
import DGis
import Foundation

class VoiceRowViewModel: ObservableObject, Identifiable, @unchecked Sendable {
	typealias UninstallVoiceCallback = (Voice) -> Void

	var id: String {
		self.voice.id
	}

	var name: String {
		"\(self.voice.info.name) (\(self.voice.language))"
	}

	var downloadAvailable: Bool {
		!self.voice.info.installed || self.voice.info.hasUpdate
	}

	var uninstallAvailable: Bool {
		self.voice.isReadyToUse && !self.voice.info.preinstalled
	}

	@Published private(set) var status: PackageStatus
	@Published var isSelected: Bool
	@Published var isUninstallRequestShown: Bool = false
	@Published var isReadyToUse: Bool

	let voice: Voice
	var uninstallVoiceCallback: UninstallVoiceCallback?
	private var infoCancellable: ICancellable = NoopCancellable()
	private var progressCancellable: ICancellable = NoopCancellable()

	init(voice: Voice, isSelected: Bool) {
		self.voice = voice
		self.isSelected = isSelected
		self.status = voice.status
		self.isReadyToUse = voice.isReadyToUse

		let updateStatusCallback: @Sendable (Any?) -> Void = {
			[weak self] _ in
			Task { @MainActor [weak self] in
				guard let self else { return }
				self.isReadyToUse = self.voice.isReadyToUse
				self.status = self.voice.status
			}
		}
		self.progressCancellable = voice.progressChannel.sinkOnMainThread(updateStatusCallback)
		self.infoCancellable = voice.infoChannel.sinkOnMainThread(updateStatusCallback)
	}

	func install() {
		self.voice.install()
		self.isReadyToUse = true
	}

	func uninstall() {
		self.voice.uninstall()
		self.uninstallVoiceCallback?(self.voice)
		self.isReadyToUse = false
	}

	func play() {
		_ = self.voice.playWelcome()
	}
}
