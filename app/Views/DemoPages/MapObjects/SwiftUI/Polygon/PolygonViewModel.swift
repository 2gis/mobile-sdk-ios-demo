import Combine
import DGis
import SwiftUI

final class PolygonViewModel: ObservableObject {
	private enum Constants {
		static let defaultContourSize = 1
		static let bearingMax = 360.0
	}

	@Published var polygonColor: MapObjectColor = .transparent
	@Published var contourSize: String = ""
	@Published var contoursCount: String = ""
	@Published var zIndex: String = "0"
	@Published var userData: String = ""
	@Published var strokeWidth: StrokeWidth = .thin
	@Published var strokeColor: MapObjectColor = .transparent
	@Published var isErrorAlertShown: Bool = false

	private let map: Map
	private lazy var mapObjectManager = MapObjectManager(map: self.map)
	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	init(
		map: Map
	) {
		self.map = map
	}

	func addPolygon() {
		let contours = self.makeContours()
		let indexValue = UInt32(self.zIndex) ?? 0
		let options = PolygonOptions(
			contours: contours,
			color: self.polygonColor.value,
			strokeWidth: self.strokeWidth.pixel,
			strokeColor: self.strokeColor.value,
			userData: self.userData,
			zIndex: .init(value: indexValue)
		)
		do {
			let polygon = try Polygon(options: options)
			self.mapObjectManager.addObject(item: polygon)
		} catch let error as SimpleError {
			self.errorMessage = error.description
		} catch {
			self.errorMessage = error.localizedDescription
		}
	}

	private func makeContours() -> [[GeoPoint]] {
		let flatPoint = self.map.camera.position.point
		let size = max(Int(self.contourSize) ?? Constants.defaultContourSize, Constants.defaultContourSize)
		let angle = Constants.bearingMax / Double(size)
		guard
			let count = Int(self.contoursCount),
			count > 0
		else {
			return []
		}

		return (1 ... count).map { _ in
			(1 ... size).map { item in
				flatPoint.move(
					bearing: Bearing(value: angle * Double(item)),
					meter: .init(value: Float.random(in: 50000.0 ... 100000.0))
				)
			}
		}
	}
}

extension PolygonViewModel: IMapObjectViewModel {
	func removeAll() {
		self.mapObjectManager.removeAll()
	}
}
