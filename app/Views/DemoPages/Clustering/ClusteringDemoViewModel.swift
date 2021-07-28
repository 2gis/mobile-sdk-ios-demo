import SwiftUI
import DGis

final class SimpleClusterRendererImpl: SimpleClusterRenderer {
	private let image: DGis.Image

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
		return SimpleClusterOptions(
			icon: self.image,
			iconMapDirection: iconMapDirection,
			text: String(objectCount),
			textStyle: textStyle,
			iconWidth: LogicalPixel(40.0),
			userData: String(objectCount)
		)
	}
}

final class ClusteringDemoViewModel: ObservableObject {
	@Published var markersCount: String = "100"

	private enum Constants {
		static let minLatitude: Double = 55.53739580689267
		static let maxLatitude: Double = 55.90242536833114
		static let minLongitude: Double = 37.47958129271865
		static let maxLongitude: Double = 37.86552191711962
	}

	private let map: Map
	private let imageFactory: IImageFactory

	private var markers: [Marker] = []
	private lazy var bicycle = {
		self.imageFactory.make(
			image: UIImage(systemName: "bicycle")!
				.withTintColor(.black)
				.applyingSymbolConfiguration(.init(scale: .small))!
		)
	}()
	private lazy var bicycleBlue = {
		self.imageFactory.make(
			image: UIImage(systemName: "bicycle")!
				.withTintColor(.blue)
				.applyingSymbolConfiguration(.init(scale: .large))!
		)
	}()
	private lazy var mapObjectManager: MapObjectManager =
		MapObjectManager.withClustering(
			map: self.map,
			logicalPixel: LogicalPixel(50.0),
			maxZoom: Zoom(18.0),
			clusterRenderer: SimpleClusterRendererImpl(image: self.bicycleBlue)
		)

	init(
		map: Map,
		imageFactory: IImageFactory
	) {
		self.map = map
		self.imageFactory = imageFactory
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
					icon: self.bicycle,
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

	private func generateLatitude() -> Double {
		Double.random(in: Constants.minLatitude...Constants.maxLatitude)
	}

	private func generateLongitude() -> Double {
		Double.random(in: Constants.minLongitude...Constants.maxLongitude)
	}

	private func installMarkers() {
		self.addMarkers()

		// Чисто текстовый.
		do {
			let position = GeoPointWithElevation(
				latitude: 55.67895765839564,
				longitude: 37.45498484931886
			)
			let options = MarkerOptions(
				position: position,
				icon: nil,
				text: "Here!",
				userData: "Text marker"
			)
			let marker = Marker(options: options)
			self.mapObjectManager.addObject(item: marker)
			self.markers.append(marker)
		}
	}
}

