import DGis

extension AudioVolume {
	init(_ volumeSource: NavigatorVoiceVolumeSource) {
		switch volumeSource {
			case .high:
				self = .standard
			case .middle:
				self = .low
			case .low:
				self = .minimal
		}
	}
}
