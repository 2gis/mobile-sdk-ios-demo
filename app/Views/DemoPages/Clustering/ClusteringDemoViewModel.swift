import SwiftUI
import DGis

final class SimpleClusterRendererImpl: SimpleClusterRenderer {
	private let image: DGis.Image
	private var idx = 0

	init(
		image: DGis.Image
	) {
		self.image = image
	}

	func renderCluster(cluster: SimpleClusterObject) -> SimpleClusterOptions {
		let textStyle = TextStyle(
			fontSize: LogicalPixel(15.0),
			textPlacement: TextPlacement.rightTop
		)
		let objectCount = cluster.objectCount
		let iconMapDirection = objectCount < 5 ? MapDirection(value: 45.0) : nil
		idx += 1
		return SimpleClusterOptions(
			icon: self.image,
			iconMapDirection: iconMapDirection,
			text: String(objectCount),
			textStyle: textStyle,
			iconWidth: LogicalPixel(30.0),
			userData: idx,
			zIndex: ZIndex(value: 6)
		)
	}
}

final class ClusteringDemoViewModel: ObservableObject {
	@Published var markersCount: String = "100"
	@Published var showMarkersMenu: Bool = false

	@Published var selectedClusterCardViewModel: ClusterCardViewModel?

	private enum Constants {
		static let minLatitude: Double = 55.53739580689267
		static let maxLatitude: Double = 55.90242536833114
		static let minLongitude: Double = 37.47958129271865
		static let maxLongitude: Double = 37.86552191711962
		static let tapRadius = ScreenDistance(value: 5)
	}

	private let map: Map
	private let imageFactory: IImageFactory
	private let toMap: CGAffineTransform

	private var getRenderedObjectsCancellable: DGis.Cancellable?
	private var selectedCluster: SimpleClusterObject?
	private var selectedCameraPosition: CameraPosition?

	private var markers: [Marker] = []
	private lazy var scooterIcon = {
		self.imageFactory.make(
			image: UIImage(named: "scooter_icon")!
		)
	}()
	private lazy var scooterModel = {
		self.imageFactory.make(
			image: UIImage(named: "scooter_model")!
		)
	}()
	private lazy var mapObjectManager: MapObjectManager =
		MapObjectManager.withClustering(
			map: self.map,
			logicalPixel: LogicalPixel(50.0),
			maxZoom: Zoom(18.0),
			clusterRenderer: SimpleClusterRendererImpl(image: self.scooterIcon)
		)

	init(
		map: Map,
		imageFactory: IImageFactory
	) {
		self.map = map
		self.imageFactory = imageFactory

		let scale = UIScreen.main.nativeScale
		self.toMap = CGAffineTransform(scaleX: scale, y: scale)

		self.installMarkers()
	}

	func addMarkers() {
		guard let count = Int(self.markersCount) else {
			return
		}

		var newMarkers: [Marker] = []
		for index in 0..<count {
			do {
				let position = GeoPointWithElevation(
					latitude: generateLatitude(),
					longitude: generateLongitude(),
					elevation: 0.0
				)
				let options = MarkerOptions(
					position: position,
					icon: self.scooterIcon,
					text: "M\(index)",
					iconWidth: LogicalPixel(5.0),
					userData: "Marker #\(index)"
				)
				let marker = Marker(options: options)
				newMarkers.append(marker)
				self.markers.append(marker)
			}
		}

		self.mapObjectManager.addObjects(objects: newMarkers)
	}
	
	func removeMarkers() {
		guard let count = Int(self.markersCount),
			  count < self.markers.count else {
			self.removeAll()
			return
		}

		self.mapObjectManager.removeObjects(objects: Array(self.markers[0..<count]))
		self.markers.removeFirst(count)
	}

	func removeAll() {
		self.mapObjectManager.removeAll()
		self.markers.removeAll()
	}

	func tap(_ location: CGPoint) {
		let mapLocation = location.applying(self.toMap)
		let tapPoint = ScreenPoint(x: Float(mapLocation.x), y: Float(mapLocation.y))
		self.tap(point: tapPoint, tapRadius: Constants.tapRadius)
	}

	private func generateLatitude() -> Double {
		Double.random(in: Constants.minLatitude...Constants.maxLatitude)
	}

	private func generateLongitude() -> Double {
		Double.random(in: Constants.minLongitude...Constants.maxLongitude)
	}

	private func installMarkers() {
		self.addMarkers()
	}

	private func tap(point: ScreenPoint, tapRadius: ScreenDistance) {
		self.hideSelectedCluster()
		self.getRenderedObjectsCancellable?.cancel()

		let cancel = self.map.getRenderedObjects(centerPoint: point, radius: tapRadius).sink(
			receiveValue: {
				infos in
				guard let info = infos.first else { return }
				DispatchQueue.main.async {
					[weak self] in
					self?.handle(selectedObject: info)
				}
			},
			failure: { error in
				print("Failed to fetch objects: \(error)")
			}
		)
		self.getRenderedObjectsCancellable = cancel
	}

	private func hideSelectedCluster() {
		if let object = self.selectedCluster,
		   let cameraPosition = self.selectedCameraPosition {
			object.setIcon(icon: scooterIcon)
			let objects = self.mapObjectManager.clusteringObjects(position: cameraPosition)
			objects.forEach { object in
				if let cluster = object as? SimpleClusterObject {
					cluster.iconOpacity = Opacity(value: 1.0)
				} else if let marker = object as? Marker {
					marker.iconOpacity = Opacity(value: 1.0)
				}
			}
		}
		self.selectedClusterCardViewModel = nil
	}

	private func handle(selectedObject: RenderedObjectInfo) {
		guard let cluster = selectedObject.item.item as? SimpleClusterObject,
			  selectedCluster?.userData as? Int != cluster.userData as? Int else {
			self.selectedCluster = nil
			return
		}

		cluster.setIcon(icon: self.scooterModel)
		cluster.iconMapDirection = nil
		self.selectedCluster = cluster
		let cameraPosition = self.map.camera.position
		self.selectedCameraPosition = cameraPosition
		let objects = self.mapObjectManager.clusteringObjects(position: cameraPosition)
		objects.forEach { object in
			if let cluster = object as? SimpleClusterObject {
				guard self.selectedCluster?.userData as? Int != cluster.userData as? Int else { return }
				cluster.iconOpacity = Opacity(value: 0.5)
			} else if let marker = object as? Marker {
				marker.iconOpacity = Opacity(value: 0.5)
			}
		}

		self.selectedClusterCardViewModel = ClusterCardViewModel(
			clusterObject: cluster,
			onClose: {
				[weak self] in
				self?.hideSelectedCluster()
			}
		)
	}
}

