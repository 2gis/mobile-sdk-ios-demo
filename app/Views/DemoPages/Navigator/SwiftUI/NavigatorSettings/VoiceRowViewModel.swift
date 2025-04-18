import Foundation
import Combine
import DGis

class VoiceRowViewModel: ObservableObject, Identifiable {
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

		let updateStatusCallback: (Any?) -> Void = {
			[weak self] _ in
			guard let self = self else { return }
			self.isReadyToUse = self.voice.isReadyToUse
			self.status = self.voice.status
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
