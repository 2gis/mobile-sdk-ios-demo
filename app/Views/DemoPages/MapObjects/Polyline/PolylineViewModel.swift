import SwiftUI
import DGis

final class PolylineViewModel: ObservableObject {
	private enum Constants {
		static let bearingMax = 360.0
	}

	@Published var pointsCount: String = ""
	@Published var polylineWidth: StrokeWidth = .thin
	@Published var polylineColor: MapObjectColor = .transparent
	@Published var isErrorAlertShown: Bool = false

	private let map: Map
	private let mapObjectManager: MapObjectManager
	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	init(
		map: Map,
		mapObjectManager: MapObjectManager
	) {
		self.map = map
		self.mapObjectManager = mapObjectManager
	}

	func addPolyline() {
		let points = self.makePoints()
		let options = PolylineOptions(
			points: points,
			width: self.polylineWidth.pixel,
			color: self.polylineColor.value
		)
		do {
			let polyline = try Polyline(options: options)
			self.mapObjectManager.addObject(item: polyline)
		} catch let error as SimpleError {
			self.errorMessage = error.description
		} catch {
			self.errorMessage = error.localizedDescription
		}
	}

	private func makePoints() -> [GeoPoint] {
		let flatPoint = self.map.camera.position.point
		guard
			let size = Int(self.pointsCount),
			size > 0
		else {
			return []
		}
		let angle = Constants.bearingMax / Double(size)

		return (1...size).map { item in
			flatPoint.move(
				bearing: Bearing(value: angle * Double(item)),
				meter: .init(value: Float.random(in: 50000.0...100000.0))
			)
		}
	}
}
