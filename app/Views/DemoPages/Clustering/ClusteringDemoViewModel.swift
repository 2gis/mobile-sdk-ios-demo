import SwiftUI
import DGis

enum GroupingType {
	case clustering, generalization
}

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
	@Published var groupingType: GroupingType = .clustering {
		didSet {
			if oldValue != self.groupingType {
				self.reinitMapObjectManager()
			}
		}
	}

	@Published var isVisible: Bool = true {
		didSet {
			if oldValue != self.isVisible {
				self.mapObjectManager?.isVisible = self.isVisible
			}
		}
	}

	@Published var markersCount: UInt32 = 100
	@Published var minZoom: UInt32 = 0
	@Published var maxZoom: UInt32 = 19
	@Published var showDetailsSettings: Bool = false
	@Published var showMarkersMenu: Bool = false
	@Published var isErrorAlertShown: Bool = false

	@Published var selectedClusterCardViewModel: ClusterCardViewModel?

	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	private enum Constants {
		static let minLatitude: Double = 55.53739580689267
		static let maxLatitude: Double = 55.90242536833114
		static let minLongitude: Double = 37.47958129271865
		static let maxLongitude: Double = 37.86552191711962
		static let white: DGis.Color = .init(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
		static let red: DGis.Color = .init(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
		static let textStyle = TextStyle(
			fontSize: LogicalPixel(10.0),
			color: Constants.white,
			strokeWidth: LogicalPixel(5.0),
			strokeColor: Constants.red,
			textOffset: LogicalPixel(1.0)
		)
	}

	private let map: Map
	private let imageFactory: IImageFactory
	private var selectedCluster: MapObject?
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
	private lazy var mapObjectManager: MapObjectManager? = self.makeMapObjectManager()

	init(
		map: Map,
		imageFactory: IImageFactory
	) {
		self.map = map
		self.imageFactory = imageFactory

		self.installMarkers()
	}

	func addMarkers() {
		let newMarkers: [Marker] = self.makeNewMarkers(count: Int(self.markersCount))
		self.mapObjectManager?.addObjects(objects: newMarkers)
	}
	
	func removeMarkers() {
		guard self.markersCount < self.markers.count else {
			self.removeAll()
			return
		}

		self.mapObjectManager?.removeObjects(objects: Array(self.markers[0..<Int(self.markersCount)]))
		self.markers.removeFirst(Int(self.markersCount))
	}

	func removeAndAddMarkers() {
		var count = Int(self.markersCount)
		if self.markersCount > self.markers.count {
			count = self.markers.count
		}

		let objectsToRemove = Array(self.markers[0..<count])
		self.markers.removeFirst(count)

		let newMarkers: [Marker] = self.makeNewMarkers(count: count)

		self.mapObjectManager?.removeAndAddObjects(
			objectsToRemove: objectsToRemove,
			objectsToAdd: newMarkers
		)
	}

	func removeAll() {
		self.mapObjectManager?.removeAll()
		self.markers.removeAll()
	}

	func reinitMapObjectManager() {
		DispatchQueue.main.async {
			self.mapObjectManager = nil
			self.markers.removeAll()
			self.mapObjectManager = self.makeMapObjectManager()
		}
	}

	func tap(objectInfo: RenderedObjectInfo) {
		self.hideSelectedCluster()
		self.handle(selectedObject: objectInfo)
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

	private func hideSelectedCluster() {
		guard
			let object = self.selectedCluster,
			let cameraPosition = self.selectedCameraPosition
		else {
			self.selectedClusterCardViewModel = nil
			return
		}

		switch object {
			case let cluster as SimpleClusterObject:
				cluster.setIcon(icon: self.scooterIcon)
			case let marker as Marker:
				marker.icon = self.scooterIcon
			default:
				return
		}

		self.selectedClusterCardViewModel = nil
		let objects = self.mapObjectManager?.clusteringObjects(position: cameraPosition)
		objects?.forEach { object in
			if let cluster = object as? SimpleClusterObject {
				cluster.iconOpacity = Opacity(value: 1.0)
			} else if let marker = object as? Marker {
				marker.iconOpacity = Opacity(value: 1.0)
			}
		}
	}

	private func handle(selectedObject: RenderedObjectInfo) {
		switch selectedObject.item.item {
			case let cluster as SimpleClusterObject:
				self.clusterHandle(cluster: cluster)
			case let marker as Marker:
				self.markerHandle(marker: marker)
			default:
				return
		}
	}

	private func clusterHandle(cluster: SimpleClusterObject) {
		guard selectedCluster?.userData as? Int != cluster.userData as? Int else {
			self.selectedCluster = nil
			return
		}

		cluster.setIcon(icon: self.scooterModel)
		cluster.iconMapDirection = nil
		self.selectedCluster = cluster
		let cameraPosition = self.map.camera.position
		self.selectedCameraPosition = cameraPosition
		self.hideMarkersOnCameraPosition(cameraPosition: cameraPosition)

		self.selectedClusterCardViewModel = ClusterCardViewModel(
			mapObject: cluster,
			onClose: {
				[weak self] in
				self?.hideSelectedCluster()
			}
		)
	}

	private func markerHandle(marker: Marker) {
		guard self.groupingType == .generalization else { return }

		guard selectedCluster?.userData as? String != marker.userData as? String else {
			self.selectedCluster = nil
			return
		}

		marker.icon = self.scooterModel
		marker.iconMapDirection = nil
		self.selectedCluster = marker
		let cameraPosition = self.map.camera.position
		self.selectedCameraPosition = cameraPosition
		self.hideMarkersOnCameraPosition(cameraPosition: cameraPosition)

		self.selectedClusterCardViewModel = ClusterCardViewModel(
			mapObject: marker,
			onClose: {
				[weak self] in
				self?.hideSelectedCluster()
			}
		)
	}

	private func hideMarkersOnCameraPosition(cameraPosition: CameraPosition) {
		let objects = self.mapObjectManager?.clusteringObjects(position: cameraPosition)
		objects?.forEach { object in
			switch object {
				case let cluster as SimpleClusterObject:
					guard self.selectedCluster?.userData as? Int != object.userData as? Int else { return }
					cluster.iconOpacity = Opacity(value: 0.5)
				case let marker as Marker:
					guard self.selectedCluster?.userData as? String != object.userData as? String else { return }
					marker.iconOpacity = Opacity(value: 0.5)
				default:
					return
			}
		}
	}

	private func makeMapObjectManager() -> MapObjectManager {
		switch self.groupingType {
			case .clustering:
				return MapObjectManager.withClustering(
					map: self.map,
					logicalPixel: LogicalPixel(80.0),
					maxZoom: Zoom(floatLiteral: Float(self.maxZoom)),
					clusterRenderer: SimpleClusterRendererImpl(image: self.scooterIcon),
					minZoom: Zoom(floatLiteral: Float(self.minZoom))
				)
			case .generalization:
				return MapObjectManager.withGeneralization(
					map: self.map,
					logicalPixel: LogicalPixel(80.0),
					maxZoom: Zoom(floatLiteral: Float(self.maxZoom)),
					minZoom: Zoom(floatLiteral: Float(self.minZoom))
				)
		}
	}

	private func makeNewMarkers(count: Int) -> [Marker] {
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
					textStyle: Constants.textStyle,
					iconWidth: LogicalPixel(5.0),
					userData: "Marker #\(index)"
				)
				let marker: Marker
				do {
					marker = try Marker(options: options)
				} catch let error as SimpleError {
					self.errorMessage = error.description
					continue
				} catch {
					self.errorMessage = error.localizedDescription
					continue
				}
				newMarkers.append(marker)
				self.markers.append(marker)
			}
		}
		return newMarkers
	}
}
