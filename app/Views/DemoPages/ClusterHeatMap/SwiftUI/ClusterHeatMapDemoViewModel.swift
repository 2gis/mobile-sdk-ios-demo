import DGis
import SwiftUI

@MainActor
final class ClusterHeatMapDemoViewModel: ObservableObject {
	private enum Constants {
		static let moscow = GeoPoint(latitude: 55.755864, longitude: 37.617698)
		static let initialCameraPosition = CameraPosition(
			point: Constants.moscow,
			zoom: Zoom(value: 10.4)
		)
		static let clusterRadius = LogicalPixel(value: 28.0)
		static let clustersEndAtZoom = Zoom(value: 15.5)
		static let heatSpotWidth = LogicalPixel(value: 72.0)
		static let markerCount = 100000
		static let markerBatchSize = 5000
	}

	@Published private(set) var isReady = false
	@Published var isErrorAlertShown = false

	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	private let mapFactory: IMapFactory
	private let imageFactory: IImageFactory
	private let logger: ILogger
	private var map: Map?
	private var mapObjectManager: MapObjectManager?
	private var installationTask: Task<Void, Never>?

	init(mapFactory: IMapFactory, imageFactory: IImageFactory, logger: ILogger) {
		self.mapFactory = mapFactory
		self.imageFactory = imageFactory
		self.logger = logger
		let markerCount = Constants.markerCount
		self.installationTask = Task { @MainActor [weak self] in
			// Return control to SwiftUI before the map starts accepting a large data set.
			await Task.yield()
			guard let self else { return }
			do {
				let map = try await self.mapFactory.mapAsync
				self.map = map
				guard !Task.isCancelled else { return }

				let points = await Task.detached(priority: .userInitiated) {
					HeatMapPointAggregator.aggregate(
						HeatMapPointGenerator.makePoints(count: markerCount)
					)
				}.value
				guard !Task.isCancelled else { return }
				await self.installHeatMap(on: map, points: points)
			} catch {
				self.errorMessage = error.localizedDescription
				self.logger.error("Failed to configure cluster heat map: \(error)")
			}
		}
	}

	deinit {
		self.installationTask?.cancel()
	}

	func resetCamera() {
		try? self.map?.camera.setPosition(position: Constants.initialCameraPosition)
	}

	private func installHeatMap(
		on map: Map,
		points: [HeatMapPointGenerator.HeatMapPoint]
	) async {
		do {
			try map.camera.setPosition(position: Constants.initialCameraPosition)
		} catch {
			self.errorMessage = error.localizedDescription
			self.logger.error("Failed to configure cluster heat map: \(error)")
			return
		}

		let imagePalette = HeatMapImagePalette(
			images: HeatMapIntensity.buckets.map { self.makeHeatSpotIcon(intensity: $0) }
		)
		let manager = MapObjectManager.withClustering(
			map: map,
			logicalPixel: Constants.clusterRadius,
			maxZoom: Constants.clustersEndAtZoom,
			clusterRenderer: ClusterHeatMapRenderer(imagePalette: imagePalette),
			minZoom: Zoom(value: 0.0)
		)
		self.mapObjectManager = manager

		for batchStart in stride(from: 0, to: points.count, by: Constants.markerBatchSize) {
			guard !Task.isCancelled else { return }
			let batchEnd = min(batchStart + Constants.markerBatchSize, points.count)
			let markers = self.makeMarkers(
				for: points[batchStart ..< batchEnd],
				imagePalette: imagePalette
			)
			manager.addObjects(objects: markers)
			await Task.yield()
		}

		self.isReady = true
	}

	private func makeMarkers(
		for points: ArraySlice<HeatMapPointGenerator.HeatMapPoint>,
		imagePalette: HeatMapImagePalette
	) -> [SimpleMapObject] {
		var markers: [SimpleMapObject] = []
		markers.reserveCapacity(points.count)

		for heatMapPoint in points {
			do {
				let marker = try Marker(options: MarkerOptions(
					position: GeoPointWithElevation(
						latitude: Latitude(floatLiteral: heatMapPoint.latitude),
						longitude: Longitude(floatLiteral: heatMapPoint.longitude)
					),
					icon: imagePalette.image(for: heatMapPoint.dbIntensity),
					iconWidth: Constants.heatSpotWidth,
					userData: HeatMapPointPayload(dbIntensity: heatMapPoint.dbIntensity),
					zIndex: ZIndex(value: 1),
					animatedAppearance: false,
					suppressOnOverlap: false
				))
				markers.append(marker)
			} catch {
				self.logger.error("Failed to create heat map marker: \(error)")
			}
		}

		return markers
	}

	private func makeHeatSpotIcon(intensity: Double) -> DGis.Image {
		let size = CGSize(width: 128.0, height: 128.0)
		let renderer = UIGraphicsImageRenderer(size: size)
		let image = renderer.image { context in
			let center = CGPoint(x: size.width / 2.0, y: size.height / 2.0)
			let color = UIColor.systemOrange
			let centerOpacity = HeatMapIntensity.centerOpacity(for: intensity)
			let colors = [
				color.withAlphaComponent(centerOpacity).cgColor,
				color.withAlphaComponent(centerOpacity * 0.65).cgColor,
				color.withAlphaComponent(0.0).cgColor,
			] as CFArray
			let locations: [CGFloat] = [0.0, 0.38, 1.0]
			let gradient = CGGradient(
				colorsSpace: CGColorSpaceCreateDeviceRGB(),
				colors: colors,
				locations: locations
			)!
			context.cgContext.drawRadialGradient(
				gradient,
				startCenter: center,
				startRadius: 0.0,
				endCenter: center,
				endRadius: size.width / 2.0,
				options: []
			)
		}
		return self.imageFactory.make(image: image)
	}
}

private nonisolated enum HeatMapPointGenerator {
	struct HeatMapPoint: Sendable {
		let latitude: Double
		let longitude: Double
		let dbIntensity: Double
	}

	private struct HotSpot: Sendable {
		let latitude: Double
		let longitude: Double
		let latitudeSpread: Double
		let longitudeSpread: Double
	}

	private static let hotSpots = [
		HotSpot(latitude: 55.7558, longitude: 37.6177, latitudeSpread: 0.032, longitudeSpread: 0.052),
		HotSpot(latitude: 55.7350, longitude: 37.6550, latitudeSpread: 0.025, longitudeSpread: 0.038),
		HotSpot(latitude: 55.7760, longitude: 37.5950, latitudeSpread: 0.022, longitudeSpread: 0.035),
		HotSpot(latitude: 55.7040, longitude: 37.5900, latitudeSpread: 0.027, longitudeSpread: 0.040),
		HotSpot(latitude: 55.8120, longitude: 37.6400, latitudeSpread: 0.025, longitudeSpread: 0.040),
		HotSpot(latitude: 55.6700, longitude: 37.5200, latitudeSpread: 0.030, longitudeSpread: 0.050),
	]

	static func makePoints(count: Int) -> [HeatMapPoint] {
		var generator = Generator(seed: 0x2D15C0DE)
		var points: [HeatMapPoint] = []
		points.reserveCapacity(count)
		for _ in 0 ..< count {
			points.append(generator.nextPoint())
		}
		return points
	}

	private struct Generator {
		private var state: UInt64

		init(seed: UInt64) {
			self.state = seed
		}

		mutating func nextPoint() -> HeatMapPoint {
			let hotSpot = HeatMapPointGenerator.hotSpots[
				Int(self.nextUnit() * Double(HeatMapPointGenerator.hotSpots.count))
			]
			let latitude = hotSpot.latitude + self.nextCenteredValue() * hotSpot.latitudeSpread
			let longitude = hotSpot.longitude + self.nextCenteredValue() * hotSpot.longitudeSpread
			return HeatMapPoint(
				latitude: latitude,
				longitude: longitude,
				dbIntensity: 1.0
			)
		}

		private mutating func nextUnit() -> Double {
			self.state = self.state &* 6364136223846793005 &+ 1
			return Double(self.state >> 11) / Double(1 << 53)
		}

		private mutating func nextCenteredValue() -> Double {
			(self.nextUnit() + self.nextUnit() + self.nextUnit() + self.nextUnit() - 2.0) / 2.0
		}
	}
}

private nonisolated enum HeatMapPointAggregator {
	private struct CoordinateKey: Hashable {
		let latitude: Int64
		let longitude: Int64
	}

	private static let coordinatePrecision = 1000000.0

	static func aggregate(_ points: [HeatMapPointGenerator.HeatMapPoint]) -> [HeatMapPointGenerator.HeatMapPoint] {
		var pointsByCoordinate: [CoordinateKey: HeatMapPointGenerator.HeatMapPoint] = [:]
		pointsByCoordinate.reserveCapacity(points.count)

		for point in points {
			let key = CoordinateKey(
				latitude: Int64((point.latitude * self.coordinatePrecision).rounded()),
				longitude: Int64((point.longitude * self.coordinatePrecision).rounded())
			)
			if let existingPoint = pointsByCoordinate[key] {
				pointsByCoordinate[key] = .init(
					latitude: existingPoint.latitude,
					longitude: existingPoint.longitude,
					dbIntensity: existingPoint.dbIntensity + point.dbIntensity
				)
			} else {
				pointsByCoordinate[key] = point
			}
		}

		return Array(pointsByCoordinate.values)
	}
}

private nonisolated enum HeatMapIntensity {
	static let buckets: [Double] = [
		1.0, 2.0, 4.0, 8.0, 16.0, 32.0, 64.0, 128.0, 256.0,
		512.0, 1024.0, 2048.0, 4096.0, 8192.0, 16384.0,
		32768.0, 65536.0, 100000.0,
	]

	static func centerOpacity(for intensity: Double) -> CGFloat {
		let opacityPerIntensityUnit = 0.012
		let normalizedIntensity = max(intensity, 0.0)
		return CGFloat(1.0 - pow(1.0 - opacityPerIntensityUnit, normalizedIntensity))
	}
}

private final nonisolated class HeatMapPointPayload: @unchecked Sendable {
	let dbIntensity: Double

	init(dbIntensity: Double) {
		self.dbIntensity = dbIntensity
	}
}

private final nonisolated class HeatMapImagePalette: @unchecked Sendable {
	private let images: [DGis.Image]

	init(images: [DGis.Image]) {
		self.images = images
	}

	func image(for intensity: Double) -> DGis.Image {
		let bucketIndex = HeatMapIntensity.buckets.firstIndex { $0 >= intensity }
			?? HeatMapIntensity.buckets.indices.last!
		return self.images[bucketIndex]
	}
}

private final nonisolated class ClusterHeatMapRenderer: SimpleClusterRenderer {
	private let imagePalette: HeatMapImagePalette

	init(imagePalette: HeatMapImagePalette) {
		self.imagePalette = imagePalette
	}

	func renderCluster(cluster: SimpleClusterObject) -> SimpleClusterOptions {
		let dbIntensity = cluster.objects.reduce(0.0) { sum, object in
			sum + ((object.userData as? HeatMapPointPayload)?.dbIntensity ?? 0.0)
		}

		return SimpleClusterOptions(
			icon: self.imagePalette.image(for: dbIntensity),
			iconWidth: LogicalPixel(value: 72.0),
			zIndex: ZIndex(value: 2),
			animatedAppearance: false,
			suppressOnOverlap: false
		)
	}
}
