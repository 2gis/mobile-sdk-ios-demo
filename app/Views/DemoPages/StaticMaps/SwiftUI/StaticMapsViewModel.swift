import SwiftUI
import DGis

struct SnapshotData {
	var snapshot: UIImage
	var startPoint: String
	var endPoint: String
}

final class StaticMapsViewModel: ObservableObject {
	@Published var snapshotData: [SnapshotData] = []
	@Published var needMapViewToExist: Bool = false
	private let map: Map
	private let logger: ILogger
	private let	imageFactory: IImageFactory
	private let snapshotter: IMapSnapshotter
	private let mapObjectManager: MapObjectManager

	private var cancellables: [ICancellable] = []
	private var mapSnapshotOperation: ICancellable?

	init(
		map: Map,
		logger: ILogger,
		imageFactory: IImageFactory,
		snapshotter: IMapSnapshotter
	) {
		self.map = map
		self.logger = logger
		self.imageFactory = imageFactory
		self.snapshotter = snapshotter
		self.mapObjectManager = MapObjectManager(map: map)
		self.map.interactive = false
		self.map.camera.padding = Padding(left: 50, top: 50, right: 50, bottom: 50)
	}

	func makeMapSnapshots() {
		self.mapSnapshotOperation?.cancel()
		self.snapshotData = []
		self.mapObjectManager.removeAll()
		self.cancellables.removeAll()
		self.needMapViewToExist = true

		self.mapSnapshotOperation = self.map.camera.sizeChannel.sink { [weak self] size in
			guard let self = self, size != ScreenSize(width: 0, height: 0) else { return }
			let staticMapRoutes = StaticMapRouteFactory(imageFactory: self.imageFactory)
			self.moveCameraAndTakeSnapshot(counter: 0, staticMapRoutes: staticMapRoutes)
		}
	}

	func moveCameraAndTakeSnapshot(counter: Int, staticMapRoutes: StaticMapRouteFactory) {
		//If taken snapshots for all routes, then stop snapshotting
		guard counter < staticMapRoutes.StaticMapsRoutes.count else {
			DispatchQueue.main.async {
				self.needMapViewToExist = false
			}
			return
		}
		let route = staticMapRoutes.StaticMapsRoutes[counter]
		let mapObjects = route.routeObjects
		self.mapObjectManager.addObjects(objects: mapObjects)
		let position = calcPosition(camera: self.map.camera, objects: mapObjects)
		let moveCancellable = self.map.camera.move(
			position: position,
			time: 0,
			animationType: .linear
		).sink(
			receiveValue: { [weak self] result in
				guard let self = self else { return }
				let snapshootCancellable = self.snapshotter.makeImage().sinkOnMainThread(
					receiveValue: { [weak self] snapshot in
						guard let self = self else { return }
						self.snapshotData.append(
							SnapshotData(
								snapshot: snapshot,
								startPoint: route.startPoint,
								endPoint: route.finishPoint)
						)
						self.mapObjectManager.removeObjects(objects: mapObjects)
						self.moveCameraAndTakeSnapshot(counter: counter + 1, staticMapRoutes: staticMapRoutes)
					},
					failure: { [weak self] error in
						guard let self = self else { return }
						self.mapObjectManager.removeObjects(objects: mapObjects)
						self.logger.error("Something went wrong with snapshot: \(error.localizedDescription)")
					}
				)
				self.cancellables.append(snapshootCancellable)
			},
			failure: { [weak self] error in
				guard let self = self else { return }
				self.mapObjectManager.removeObjects(objects: mapObjects)
				self.logger.error("Something went wrong with camera move: \(error.localizedDescription)")
			}
		)
		self.cancellables.append(moveCancellable)
	}
}
