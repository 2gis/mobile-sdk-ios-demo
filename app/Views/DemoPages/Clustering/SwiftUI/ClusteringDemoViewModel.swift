import Combine
import DGis
import SwiftUI

enum GroupingType: String, CaseIterable {
	case clustering, generalization, noGrouping
}

enum ClusterMapObjectType: String, CaseIterable {
	case marker, lottie, model

	var dataName: String {
		switch self {
		case .marker:
			"svg/marker_search"
		case .lottie:
			"lottie/animated_marker_blue"
		case .model:
			"models/cubes_with_scenes"
		@unknown default:
			fatalError("Unknown type: \(self)")
		}
	}

	var selectedDataName: String {
		switch self {
		case .marker:
			"svg/marker_search_selected"
		case .lottie:
			"lottie/animated_marker_green"
		case .model:
			"models/cubes_fly"
		@unknown default:
			fatalError("Unknown type: \(self)")
		}
	}

	var width: LogicalPixel {
		switch self {
		case .marker:
			LogicalPixel(5.0)
		case .lottie:
			LogicalPixel(15.0)
		case .model:
			LogicalPixel(10.0)
		@unknown default:
			fatalError("Unknown type: \(self)")
		}
	}
}

final class ClusteringDemoViewModel: ObservableObject, @unchecked Sendable {
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

	@Published var mapObjectType: ClusterMapObjectType = .marker {
		didSet {
			if oldValue != self.mapObjectType {
				self.reinitMapObjectManager()
			}
		}
	}

	@Published var useTextInCluster: Bool = true {
		didSet {
			if oldValue != self.useTextInCluster {
				self.reinitMapObjectManager()
			}
		}
	}

	@Published var isMapObjectsVisible: Bool = true {
		didSet {
			if oldValue != self.isMapObjectsVisible {
				for object in self.mapObjects {
					object.isVisible = self.isMapObjectsVisible
				}
			}
		}
	}

	@Published var objectsCount: UInt32 = 100
	@Published var groupingWidth: Float = 80.0
	@Published var minZoom: Float = 0.0
	@Published var maxZoom: Float = 19.0
	@Published var animationIndex: Int32 = 0
	@Published var showDetailsSettings: Bool = false
	@Published var showMapObjectsMenu: Bool = false
	@Published var isErrorAlertShown: Bool = false

	@Published var selectedClusterCardViewModel: ClusterCardViewModel?

	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	private enum Constants {
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
	private let modelFactory: IModelFactory
	private let logger: ILogger
	private var selectedCluster: MapObject?
	private var selectedCameraPosition: CameraPosition?

	private var mapObjects: [SimpleMapObject] = []
	private lazy var secondSelectedSearchMarker = self.imageFactory.make(
		image: UIImage(named: "svg/marker_search_selected_2")!
	)

	private lazy var mapObjectManager: MapObjectManager? = self.makeMapObjectManager()
	private lazy var cache: [String: ImageOrData] = [:]
	private var objectCounter = 0

	init(
		map: Map,
		mapSourceFactory: IMapSourceFactory,
		imageFactory: IImageFactory,
		modelFactory: IModelFactory,
		logger: ILogger
	) {
		self.map = map
		self.imageFactory = imageFactory
		self.modelFactory = modelFactory
		self.logger = logger

		let locationSource = mapSourceFactory.makeMyLocationMapObjectSource(
			bearingSource: .satellite
		)
		self.map.addSource(source: locationSource)

		self.installMapObjects()
	}

	func addMapObjects() {
		let newMapObjects = self.makeNewMapObjects(count: Int(self.objectsCount))
		self.mapObjectManager?.addObjects(objects: newMapObjects)
	}

	func removeMapObjects() {
		guard self.objectsCount < self.mapObjects.count else {
			self.removeAll()
			return
		}

		self.mapObjectManager?.removeObjects(objects: Array(self.mapObjects[0 ..< Int(self.objectsCount)]))
		self.mapObjects.removeFirst(Int(self.objectsCount))
	}

	func removeAndAddMapObjects() {
		var count = Int(self.objectsCount)
		if self.objectsCount > self.mapObjects.count {
			count = self.mapObjects.count
		}

		let objectsToRemove = Array(self.mapObjects[0 ..< count])
		self.mapObjects.removeFirst(count)

		let newObjects = self.makeNewMapObjects(count: count)

		self.mapObjectManager?.removeAndAddObjects(
			objectsToRemove: objectsToRemove,
			objectsToAdd: newObjects
		)
	}

	func removeAll() {
		self.mapObjectManager?.removeAll()
		self.mapObjects.removeAll()
	}

	func moveObjectsAndDeleteThem() {
		let pt1 = GeoPoint(latitude: 55.817026, longitude: 37.507916)
		let pt2 = GeoPoint(latitude: 54.817026, longitude: 37.507916)

		let polylineOptions = PolylineOptions(
			points: [pt1, pt2],
			width: 10.0,
			color: Color(UIColor.black)!
		)
		let polyline: Polyline
		do {
			polyline = try Polyline(options: polylineOptions)
		} catch let error as SimpleError {
			self.errorMessage = error.description
			return
		} catch {
			self.errorMessage = error.localizedDescription
			return
		}
		self.mapObjectManager?.addObject(item: polyline)

		guard
			let mapObject = self.makeNewMapObject(
				position: GeoPointWithElevation(point: pt1),
				index: 0
			)
		else {
			return
		}
		self.mapObjectManager?.addObject(item: mapObject)

		DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
			self.mapObjectManager?.removeObject(item: polyline)
			self.mapObjectManager?.removeObject(item: mapObject)

			DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
				polyline.color = Color(UIColor.red)!
				if let marker = mapObject as? Marker {
					marker.iconOpacity = Opacity(value: 0.9)
				}
			}
		}
	}

	func reinitMapObjectManager() {
		/// Есть проблема, что если у вновь добавленного маркера поменять позицию, а потом удалить MapObjectManager, то будет краш.
		if !self.mapObjects.isEmpty, let marker = self.mapObjects[0] as? Marker {
			marker.position = self.generateGeoPoint()
		}

		DispatchQueue.main.async {
			self.selectedCluster = nil
			self.selectedCameraPosition = nil
			self.mapObjectManager = nil
			self.mapObjects.removeAll()
			self.mapObjectManager = self.makeMapObjectManager()
		}
	}

	func moveAllMapObjects() {
		for object in self.mapObjects {
			let position = self.generateGeoPoint()

			switch object {
			case let marker as Marker:
				marker.position = position
			case let model as ModelMapObject:
				model.position = position
			default:
				continue
			}
		}
	}

	func tap(objectInfo: RenderedObjectInfo) {
		self.hideSelectedCluster()
		self.handle(selectedObject: objectInfo)
	}

	func longPress(objectInfo: RenderedObjectInfo) {
		guard let marker = objectInfo.item.item as? Marker else { return }
		marker.position = self.generateGeoPoint()
	}

	private func generateGeoPoint() -> GeoPointWithElevation {
		let visibleRect = self.map.camera.visibleRect
		let minPoint = visibleRect.southWestPoint
		let maxPoint = visibleRect.northEastPoint
		let minLongitude = minPoint.longitude.value
		var maxLongitude = maxPoint.longitude.value
		if minLongitude > maxLongitude {
			maxLongitude = max(maxLongitude + 180, 180)
		}
		let latitude = Double.random(in: minPoint.latitude.value ... maxPoint.latitude.value)
		let longitude = Double.random(in: minLongitude ... maxLongitude)
		return GeoPointWithElevation(
			latitude: latitude,
			longitude: longitude,
			elevation: 0.0
		)
	}

	private func installMapObjects() {
		self.addMapObjects()
	}

	private func hideSelectedCluster() {
		guard
			let object = self.selectedCluster,
			let cameraPosition = self.selectedCameraPosition
		else {
			self.selectedClusterCardViewModel = nil
			return
		}

		let objectData = self.load(dataName: self.mapObjectType.dataName)
		switch object {
		case let cluster as SimpleClusterObject:
			cluster.setIcon(icon: objectData.image)
		case let marker as Marker:
			marker.icon = objectData.image
		case let model as ModelMapObject:
			model.modelData = objectData.data
		default:
			return
		}

		self.selectedClusterCardViewModel = nil
		let objects = self.mapObjectManager?.clusteringObjects(position: cameraPosition)
		objects?.forEach { object in
			switch object {
			case let cluster as SimpleClusterObject:
				cluster.setIcon(icon: self.load(dataName: self.mapObjectType.dataName).image)
			case let marker as Marker:
				marker.iconOpacity = Opacity(value: 1.0)
			case let model as ModelMapObject:
				model.opacity = Opacity(value: 1.0)
			default:
				return
			}
		}
	}

	private func handle(selectedObject: RenderedObjectInfo) {
		switch selectedObject.item.item {
		case let cluster as SimpleClusterObject:
			self.clusterHandle(cluster: cluster)
		case let marker as Marker:
			self.markerHandle(marker: marker)
		case let model as ModelMapObject:
			self.modelHandler(model: model)
		default:
			return
		}
	}

	private func clusterHandle(cluster: SimpleClusterObject) {
		guard self.selectedCluster?.userData as? Int != cluster.userData as? Int else {
			self.selectedCluster = nil
			return
		}

		cluster.setIcon(icon: self.load(dataName: self.mapObjectType.selectedDataName).image)
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

		guard self.selectedCluster?.userData as? Int != marker.userData as? Int else {
			self.selectedCluster = nil
			return
		}

		marker.icon = self.load(dataName: self.mapObjectType.selectedDataName).image
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

	private func modelHandler(model: ModelMapObject) {
		guard self.groupingType == .generalization else { return }

		guard self.selectedCluster?.userData as? Int != model.userData as? Int else {
			self.selectedCluster = nil
			return
		}

		model.modelData = self.load(dataName: ClusterMapObjectType.model.selectedDataName).data
		model.mapDirection = nil
		self.selectedCluster = model
		let cameraPosition = self.map.camera.position
		self.selectedCameraPosition = cameraPosition
		self.hideMarkersOnCameraPosition(cameraPosition: cameraPosition)

		self.selectedClusterCardViewModel = ClusterCardViewModel(
			mapObject: model,
			onClose: {
				[weak self] in
				self?.hideSelectedCluster()
			}
		)
	}

	private func hideMarkersOnCameraPosition(cameraPosition: CameraPosition) {
		let objects = self.mapObjectManager?.clusteringObjects(position: cameraPosition)
		objects?.forEach { object in
			guard self.selectedCluster?.userData as? Int != object.userData as? Int else { return }
			switch object {
			case let cluster as SimpleClusterObject:
				cluster.setIcon(icon: self.secondSelectedSearchMarker)
			case let marker as Marker:
				marker.iconOpacity = Opacity(value: 0.5)
			case let model as ModelMapObject:
				model.opacity = Opacity(value: 0.5)
			default:
				return
			}
		}
	}

	private func makeMapObjectManager() -> MapObjectManager {
		switch self.groupingType {
		case .clustering:
			if self.mapObjectType == .model {
				return MapObjectManager(map: self.map)
			}

			return MapObjectManager.withClustering(
				map: self.map,
				logicalPixel: LogicalPixel(floatLiteral: self.groupingWidth),
				maxZoom: Zoom(floatLiteral: self.maxZoom),
				clusterRenderer: SimpleClusterRendererImpl(
					image: self.load(dataName: self.mapObjectType.dataName).image,
					useTextInCluster: self.useTextInCluster,
					userDataCreator: { [weak self] in
						let idx = self?.objectCounter
						return idx ?? 0
					}
				),
				minZoom: Zoom(floatLiteral: self.minZoom)
			)
		case .generalization:
			return MapObjectManager.withGeneralization(
				map: self.map,
				logicalPixel: LogicalPixel(floatLiteral: self.groupingWidth),
				maxZoom: Zoom(floatLiteral: self.maxZoom),
				minZoom: Zoom(floatLiteral: self.minZoom)
			)
		case .noGrouping:
			return MapObjectManager(map: self.map)
		@unknown default:
			fatalError("Unknown type: \(self.groupingType)")
		}
	}

	private func makeNewMapObjects(count: Int) -> [SimpleMapObject] {
		var newObjects: [SimpleMapObject] = []
		for _ in 0 ..< count {
			do {
				let position = self.generateGeoPoint()
				let index = self.objectCounter
				self.objectCounter += 1
				guard let mapObject = self.makeNewMapObject(position: position, index: index) else {
					continue
				}
				newObjects.append(mapObject)
				self.mapObjects.append(mapObject)
			}
		}
		return newObjects
	}

	private func makeNewMapObject(
		position: GeoPointWithElevation,
		index: Int
	) -> SimpleMapObject? {
		switch self.mapObjectType {
		case .marker:
			self.makeMarker(
				position: position,
				mapObjectType: .marker,
				index: index
			)
		case .lottie:
			self.makeMarker(
				position: position,
				mapObjectType: .lottie,
				index: index
			)
		case .model:
			self.makeModelMapObject(
				position: position,
				mapObjectType: .model,
				index: index
			)
		@unknown default:
			fatalError("Unknown type: \(self.mapObjectType)")
		}
	}

	private func makeMarker(
		position: GeoPointWithElevation,
		mapObjectType: ClusterMapObjectType,
		index: Int
	) -> Marker? {
		var options = MarkerOptions(
			position: position,
			icon: self.load(dataName: mapObjectType.dataName).image,
			visible: self.isMapObjectsVisible,
			iconWidth: mapObjectType.width,
			userData: index
		)
		if self.useTextInCluster {
			options.text = "Marker #\(index)"
			options.textStyle = Constants.textStyle
		}
		do {
			return try Marker(options: options)
		} catch let error as SimpleError {
			self.errorMessage = error.description
			return nil
		} catch {
			self.errorMessage = error.localizedDescription
			return nil
		}
	}

	private func makeModelMapObject(
		position: GeoPointWithElevation,
		mapObjectType: ClusterMapObjectType,
		index: Int
	) -> ModelMapObject? {
		let options = ModelMapObjectOptions(
			position: position,
			data: self.load(dataName: mapObjectType.dataName).data,
			size: .logicalPixel(mapObjectType.width),
			visible: self.isMapObjectsVisible,
			userData: index
		)
		do {
			let model = try ModelMapObject(options: options)
			model.animationSettings.animationIndex = self.animationIndex
			return model
		} catch let error as SimpleError {
			self.errorMessage = error.description
			return nil
		} catch {
			self.errorMessage = error.localizedDescription
			return nil
		}
	}

	private func load(dataName: String) -> ImageOrData {
		if let cachedData = cache[dataName] {
			return cachedData
		}

		let imageOrData: ImageOrData
		switch self.mapObjectType {
		case .marker:
			let pngImage = self.imageFactory.make(
				image: UIImage(named: dataName)!
			)
			imageOrData = .image(pngImage)
		case .lottie:
			let lottieImage = self.imageFactory.make(
				lottieData: NSDataAsset(name: dataName)!.data,
				size: .zero
			)
			imageOrData = .image(lottieImage)
		case .model:
			let modelData = self.modelFactory.make(
				modelData: NSDataAsset(name: dataName)!.data
			)
			imageOrData = .data(modelData)
		@unknown default:
			fatalError("Unknown type: \(self.mapObjectType)")
		}

		self.cache[dataName] = imageOrData
		return imageOrData
	}
}

private enum ImageOrData {
	case image(DGis.Image)
	case data(DGis.ModelData)

	var image: DGis.Image {
		switch self {
		case let .image(image):
			image
		case .data:
			fatalError("Unable to get image")
		@unknown default:
			fatalError("Unknown type: \(self)")
		}
	}

	var data: DGis.ModelData {
		switch self {
		case .image:
			fatalError("Unable to get model data")
		case let .data(data):
			data
		@unknown default:
			fatalError("Unknown type: \(self)")
		}
	}
}

private final class SimpleClusterRendererImpl: SimpleClusterRenderer {
	private let image: DGis.Image
	private let useTextInCluster: Bool
	private let userDataCreator: () -> Int

	init(
		image: DGis.Image,
		useTextInCluster: Bool,
		userDataCreator: @escaping () -> Int
	) {
		self.image = image
		self.useTextInCluster = useTextInCluster
		self.userDataCreator = userDataCreator
	}

	func renderCluster(cluster: SimpleClusterObject) -> SimpleClusterOptions {
		let objectCount = cluster.objectCount
		let iconMapDirection = objectCount < 5 ? MapDirection(value: 45.0) : nil
		var options = SimpleClusterOptions(
			icon: self.image,
			iconMapDirection: iconMapDirection,
			iconWidth: LogicalPixel(30.0),
			userData: self.userDataCreator(),
			zIndex: ZIndex(value: 6)
		)
		if self.useTextInCluster {
			let textStyle = TextStyle(
				fontSize: LogicalPixel(15.0),
				textPlacement: TextPlacement.rightTop
			)
			options.text = String(objectCount)
			options.textStyle = textStyle
		}
		return options
	}
}
