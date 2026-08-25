import Combine
import DGis
import SwiftUI

final class ParkingsDemoViewModel: ObservableObject, @unchecked Sendable {
	private enum Constants {
		static let tapRadius = ScreenDistance(value: 5)
		static let parkingsKey = "parkingOn"
	}

	@Published var directoryObject: DirectoryObject?
	@Published var isParkingsEnabled: Bool = true {
		didSet {
			self.updateParkings()
		}
	}

	private let map: Map
	private let logger: ILogger
	private let searchManager: SearchManager
	private var searchCancellable: ICancellable?

	init(
		map: Map,
		mapSourceFactory: IMapSourceFactory,
		searchManager: SearchManager,
		logger: ILogger
	) {
		self.map = map
		self.searchManager = searchManager
		self.logger = logger

		let locationSource = mapSourceFactory.makeMyLocationMapObjectSource(bearingSource: .magnetic)
		self.map.addSource(source: locationSource)
		self.updateParkings()
	}

	func handleTap(objectInfo: RenderedObjectInfo) {
		guard
			let mapObject = objectInfo.item.item as? DgisMapObject
		else {
			return
		}
		self.handle(mapObject)
	}

	private func handle(_ mapObject: DgisMapObject) {
		self.searchCancellable?.cancel()
		self.searchCancellable = self.searchManager.searchByDirectoryObjectIds(
			objectIds: [mapObject.id]
		)
		.sinkOnMainThread(
			receiveValue: { [weak self] objects in
				Task { @MainActor [weak self] in
					self?.directoryObject = objects.first
				}
			}, failure: { [weak self] error in
				Task { @MainActor [weak self] in
					self?.logger.error("Unable to find directory object: \(error)")
				}
			}
		)
	}

	private func updateParkings() {
		self.map.attributes.setAttributeValue(
			name: Constants.parkingsKey,
			value: .boolean(self.isParkingsEnabled)
		)
	}
}
