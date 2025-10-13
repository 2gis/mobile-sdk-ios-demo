import Combine
import DGis
import SwiftUI

final class GraphicsOptionsDemoViewModel: ObservableObject, @unchecked Sendable {
	@Published var selectedOption: GraphicsOption {
		didSet {
			if oldValue != self.selectedOption {
				self.settingsService.graphicsOption = self.selectedOption
				self.map.graphicsPreset = self.selectedOption.preset
			}
		}
	}

	@Published var recommendedOption: String = ""
	private let map: Map
	private let settingsService: ISettingsService
	private var mapGraphicsPresetHintCancellable: ICancellable?

	init(
		map: Map,
		settingsService: ISettingsService
	) {
		self.map = map
		self.settingsService = settingsService
		self.selectedOption = self.settingsService.graphicsOption
		self.setupMapGraphicsPresetHintChannel()
		self.setupCameraPosition()
	}

	private func setupCameraPosition() {
		do {
			try self.map.camera.setPosition(
				position: CameraPosition(
					point: .init(latitude: 25.235750344252637, longitude: 55.30035845004022),
					zoom: DGis.Zoom(value: 18.0),
					tilt: DGis.Tilt(value: 60.0)
				)
			)
		} catch {
			print("Failed to set camera position: \(error.localizedDescription)")
			return
		}
	}

	private func setupMapGraphicsPresetHintChannel() {
		self.mapGraphicsPresetHintCancellable = self.map.graphicsPresetHintChannel.sinkOnMainThread(
			{
				[weak self] preset in
				guard let self else { return }
				if let option = GraphicsOption.allCases.first(where: { $0.preset == preset }) {
					self.recommendedOption = option.name
				}
			}
		)
	}
}
