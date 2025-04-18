import SwiftUI
import DGis

final class MultiViewPortsDemoViewModel: ObservableObject {
	@Published var firstMapLoaded: Bool = false
	@Published var secondMapLoaded: Bool = false
	@Published var useMultiViewPorts: Bool = false {
		didSet {
			if oldValue != self.useMultiViewPorts {
				guard let firstMapSource = self.firstMapSource, let secondMapSource = self.secondMapSource else { return }
				self.secondMap.removeSource(source: self.useMultiViewPorts ? secondMapSource : firstMapSource)
				self.secondMap.addSource(source: self.useMultiViewPorts ? firstMapSource : secondMapSource)
			}
		}
	}
	let firstPosition = CameraPosition(point: GeoPoint(latitude: 55.7, longitude: 37.6), zoom: 11.0)
	let secondPosition = CameraPosition(point: GeoPoint(latitude: 55.7, longitude: 37.6), zoom: 13.0)
	private let firstMapSource: Source?
	private let secondMapSource: Source?
	private let firstMap: Map
	private let secondMap: Map
	private var firstDataLoadingStateChannelCancellable: DGis.Cancellable?
	private var secondDataLoadingStateChannelCancellable: DGis.Cancellable?

	init(
		firstMap: Map,
		secondMap: Map
	) {
		self.firstMap = firstMap
		self.secondMap = secondMap
		self.firstMapSource = firstMap.sources.first
		self.secondMapSource = secondMap.sources.first
		self.firstDataLoadingStateChannelCancellable = self.firstMap.dataLoadingStateChannel.sinkOnMainThread(
			{ [weak self] state in
				guard let self = self else { return }
				self.firstMapLoaded = state == .loaded
			}
		)
		self.secondDataLoadingStateChannelCancellable = self.secondMap.dataLoadingStateChannel.sinkOnMainThread(
			{ [weak self] state in
				guard let self = self else { return }
				self.secondMapLoaded = state == .loaded
			}
		)
		self.setInitialCameraPositions()
	}

	private func setInitialCameraPositions() {
		do {
			try self.firstMap.camera.setPosition(position: self.firstPosition)
			try self.secondMap.camera.setPosition(position: self.secondPosition)
		} catch {
			print("Failed to set initial camera positions: \(error)")
		}
	}
}
