import SwiftUI
import DGis

final class MapGeometryObjectsDemoViewModel: ObservableObject {
	@Published var showActionSheet = false
	@Published var shownFullScreenCover = false

	private let map: Map

	private var timer: Timer?
	private lazy var mapObjectManager: MapObjectManager = MapObjectManager(map: self.map)

	init(map: Map) {
		self.map = map
	}

	func startPolylineEditingTest() {
		self.timer?.invalidate()
		let pt1 = GeoPoint(latitude: 55.817026, longitude: 37.507916)
		let pt2 = GeoPoint(latitude: 54.817026, longitude: 37.507916)
		let pt3 = GeoPoint(latitude: 54.117026, longitude: 37.507916)
		let poly = Polyline(options: PolylineOptions(points: [pt1, pt2], width: 10.0, color: Color(UIColor.black)!))
		self.mapObjectManager.addObject(item: poly)

		var n = 0
		self.timer = Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
			poly.points = n % 2 == 0 ? [pt1, pt2] : [pt1, pt3]
			n += 1
		}
	}

	func removeAllObjects() {
		self.mapObjectManager.removeAll()
		self.timer?.invalidate()
		self.timer = nil
	}
}
