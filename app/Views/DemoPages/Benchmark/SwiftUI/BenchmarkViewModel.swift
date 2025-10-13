import Combine
import DGis
import SwiftUI

final class BenchmarkViewModel: ObservableObject, @unchecked Sendable {
	private enum Constants {
		static let firstCsvString: String = "Index,FPS\n"
	}

	typealias cameraPath = [(position: CameraPosition, time: TimeInterval, type: CameraAnimationType)]

	@Published var showActionSheet = false
	@Published var showMenuButton = true
	@Published var fpsValues: [(timestamp: TimeInterval, fps: Double)] = []
	let maxRefreshRate: Int

	private let map: Map
	private let logger: ILogger
	private let energyConsumption: IEnergyConsumption
	private let imageFactory: IImageFactory
	private let dateFormatter: DateFormatter
	private let objectManager: MapObjectManager
	private let geometryMapObjectSource: GeometryMapObjectSource
	private var geometryObjects: [GeometryMapObject] = []
	private var moveCameraCancellable: DGis.Cancellable?
	private lazy var cameraMoveQueue: DispatchQueue = .init(
		label: "ru.mobile.sdk.app-swiftui.camera-move-queue",
		qos: .default
	)

	@MainActor
	init(
		map: Map,
		geometryMapObjectSource: GeometryMapObjectSource,
		energyConsumption: IEnergyConsumption,
		imageFactory: IImageFactory,
		logger: ILogger
	) {
		self.maxRefreshRate = UIScreen.main.maximumFramesPerSecond
		self.dateFormatter = DateFormatter()
		self.dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
		self.map = map
		self.energyConsumption = energyConsumption
		self.imageFactory = imageFactory
		self.logger = logger
		self.objectManager = MapObjectManager(map: self.map)
		self.geometryMapObjectSource = geometryMapObjectSource
		self.map.addSource(source: self.geometryMapObjectSource)
		self.energyConsumption.setFpsCallback { [weak self] fps in
			let currentTime = Date().timeIntervalSince1970
			self?.fpsValues.append((timestamp: currentTime, fps: fps))
		}
	}

	func runTest(benchmarkPath: BenchmarkPath) {
		self.map.interactive = false
		switch benchmarkPath {
		case .moscowGeoJson:
			self.showMoscowGeoJsonZones()
		case .moscowJsonPolygons:
			self.showMoscowJsonPolygons()
		case .spbAnimatedMarkerFlight:
			self.createAnimatedMarkers()
		case .spbStaticMarkerFlight:
			self.createStaticMarkers()
		case .polygonsFlight:
			self.createTestPolygons()
		default:
			break
		}
		self.setCameraPosition(position: benchmarkPath.cameraPath[0].position)
		self.move(at: 0, path: benchmarkPath.cameraPath, reportName: benchmarkPath.reportName)
		self.fpsValues = []
	}

	private func move(at index: Int, path: cameraPath, reportName: String) {
		guard index < path.count else {
			self.saveToCSVFile(fileName: "\(reportName)_\(self.dateFormatter.string(from: Date())).csv")
			self.cleanUp()
			self.map.interactive = true
			DispatchQueue.main.async {
				self.showMenuButton = true
			}
			return
		}
		let tuple = path[index]
		self.cameraMoveQueue.async {
			self.moveCameraCancellable?.cancel()
			self.moveCameraCancellable = self.map
				.camera
				.move(
					position: tuple.position,
					time: tuple.time,
					animationType: tuple.type
				).sink(on: self.cameraMoveQueue) { [weak self] _ in
					self?.move(at: index + 1, path: path, reportName: reportName)
				} failure: { error in
					print("Something went wrong: \(error.localizedDescription)")
				}
		}
	}

	private func cleanUp() {
		self.objectManager.removeAll()
		self.geometryMapObjectSource.removeObjects(objects: self.geometryObjects)
		self.geometryObjects.removeAll()
	}

	private func createAnimatedMarkers() {
		let animatedMarkerImage = self.imageFactory.make(lottieData: NSDataAsset(name: "lottie/drone")!.data, size: .zero)
		let firstMarkerOptions = MarkerOptions(
			position: GeoPointWithElevation(
				latitude: 59.944667808846,
				longitude: 30.33568538725376
			),
			icon: animatedMarkerImage,
			iconWidth: LogicalPixel(value: 120.0),
			iconAnimationMode: .loop
		)
		let secondMarkerOptions = MarkerOptions(
			position: GeoPointWithElevation(
				latitude: 59.94394923628003,
				longitude: 30.335070239380002,
				elevation: Elevation(value: 50.0)
			),
			icon: animatedMarkerImage,
			iconWidth: LogicalPixel(value: 120.0),
			iconAnimationMode: .loop
		)
		self.createMarker(firstMarkerOptions)
		self.createMarker(secondMarkerOptions)
	}

	private func createStaticMarkers() {
		for i in 1 ... 150 {
			let randomColor = UIColor(hue: CGFloat(drand48()), saturation: 1, brightness: 1, alpha: 0.8)
			let staticMarkerImage = self.imageFactory.make(image: self.createColoredImage(systemName: "paperplane.fill", color: randomColor)!)
			let randomLatitude = Double.random(in: 59.93340961436914 ... 59.940455518313314)
			let randomLongitude = Double.random(in: 30.298198582604527 ... 30.314302733168006)
			let staticMarkerOptions = MarkerOptions(
				position: GeoPointWithElevation(
					latitude: Latitude(floatLiteral: randomLatitude),
					longitude: Longitude(floatLiteral: randomLongitude)
				),
				icon: staticMarkerImage, text: "Marker \(i)",
				iconWidth: LogicalPixel(value: 30.0)
			)
			self.createMarker(staticMarkerOptions)
		}
	}

	private func createTestPolygons() {
		let polygonOptions = PolygonOptions.testPolygons
		polygonOptions.forEach { self.createPolygon($0) }
	}

	private func createColoredImage(systemName: String, color: UIColor) -> UIImage? {
		let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
		let image = UIImage(
			systemName: systemName,
			withConfiguration: symbolConfiguration
		)?.withTintColor(
			color,
			renderingMode: .alwaysOriginal
		)
		return image
	}

	private func exportToCSV() -> String {
		var csvString = Constants.firstCsvString
		for dataPoint in self.fpsValues {
			csvString += "\(dataPoint.timestamp),\(dataPoint.fps)\n"
		}
		return csvString
	}

	private func saveToCSVFile(fileName: String) {
		let csvString = self.exportToCSV()
		if let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
			let url = path.appendingPathComponent("logs/\(fileName)")
			do {
				try csvString.write(to: url, atomically: true, encoding: .utf8)
				print("Saved to \(url)")
			} catch {
				print("Failed saving to CSV: \(error)")
			}
		}
	}

	private func setCameraPosition(position: CameraPosition) {
		do {
			try self.map.camera.setPosition(position: position)
		} catch let error as SimpleError {
			self.logger.error("Failed to set default camera state: \(error.description)")
		} catch {
			self.logger.error("Failed to set default camera state: \(error)")
		}
	}

	private func createMarker(_ options: MarkerOptions) {
		do {
			try self.objectManager.addObject(item: Marker(options: options))
		} catch let error as SimpleError {
			self.logger.error("Failed to create marker: \(error.description)")
		} catch {
			self.logger.error("Failed to create marker: \(error.localizedDescription)")
		}
	}

	private func createPolygon(_ options: PolygonOptions) {
		do {
			try self.objectManager.addObject(item: Polygon(options: options))
		} catch let error as SimpleError {
			self.logger.error("Failed to create polygon: \(error.description)")
		} catch {
			self.logger.error("Failed to create polygon: \(error.localizedDescription)")
		}
	}

	private func showMoscowGeoJsonZones() {
		guard
			let url = Bundle.main.url(forResource: "moscow_geo_json", withExtension: "json"),
			let data = try? Data(contentsOf: url)
		else {
			fatalError("No zone file")
		}

		guard let geoJson = String(data: data, encoding: .utf8) else {
			fatalError("Error creating Geo JSON")
		}
		self.geometryObjects = parseGeoJson(geoJsonData: geoJson)
		self.geometryMapObjectSource.addObjects(objects: self.geometryObjects)
	}

	private func showMoscowJsonPolygons() {
		guard
			let fillColor = Color(UIColor(hex: "#21233D").withAlphaComponent(0.1)),
			let strokeColor = Color(UIColor(hex: "#2FC25D"))
		else { fatalError("Could not cast colors") }
		let strokeWith = LogicalPixel(value: 2)
		guard let url = Bundle.main.url(forResource: "moscow_zone", withExtension: "json"),
		      let data = try? Data(contentsOf: url)
		else {
			fatalError("No zone file")
		}

		let zones: Zones = try! JSONDecoder().decode(Zones.self, from: data)
		let polygons = zones.polygons(areaId: "moscow")
		var zoneToShow: [Polygon] = []

		for coordinates in polygons {
			guard !coordinates.isEmpty else { continue }
			let contours = coordinates.map { GeoPoint(coordinate: $0) }
			let polygon = try! Polygon(
				options: PolygonOptions(
					contours: [contours],
					color: fillColor,
					strokeWidth: strokeWith,
					strokeColor: strokeColor,
					visible: true,
					zIndex: ZIndex(value: 0)
				)
			)
			zoneToShow.append(polygon)
		}
		self.objectManager.addObjects(objects: zoneToShow)
	}

	func printCameraPosition() {
		let position = self.map.camera.position
		print(
			"""
			(.init(
				point: .init(latitude: .init(value: \(position.point.latitude.value)), longitude: .init(value: \(position.point.longitude.value))),
				zoom: .init(value: \(position.zoom.value)),
				tilt: .init(value: \(position.tilt.value)),
				bearing: .init(value: \(position.bearing.value))
			), 4, .linear),
			"""
		)
	}
}
