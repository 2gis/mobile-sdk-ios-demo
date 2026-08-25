import Combine
import DGis
import SwiftUI

final class VisibleRectVisibleAreaDemoViewModel: ObservableObject {
	private enum Constants {
		static let visibleRectColor: DGis.Color = Color(red: 0, green: 1, blue: 0, alpha: 0.3)
		static let visibleAreaColor: DGis.Color = Color(red: 1, green: 0.3, blue: 0, alpha: 0.3)
	}

	private let map: Map
	private let mapObjectManager: MapObjectManager
	private let logger: ILogger
	private var visibleRectPolygon: Polygon?
	private var visibleAreaPolygon: Polygon?
	@Published var isVisibleRectShown: Bool = false
	@Published var isVisibleAreaShown: Bool = false
	@Published var isErrorAlertShown: Bool = false

	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	init(
		map: Map,
		logger: ILogger
	) {
		self.map = map
		self.mapObjectManager = MapObjectManager(map: self.map)
		self.logger = logger
	}

	func showVisibleRect() {
		guard self.isVisibleRectShown else {
			if let polygonToRemove = self.visibleRectPolygon {
				self.mapObjectManager.removeObject(item: polygonToRemove)
				self.visibleRectPolygon = nil
			}
			return
		}
		let rect = self.map.camera.visibleRect
		let southEastPoint = GeoPoint(latitude: rect.southWestPoint.latitude, longitude: rect.northEastPoint.longitude)
		let northWestPoint = GeoPoint(latitude: rect.northEastPoint.latitude, longitude: rect.southWestPoint.longitude)
		let options = PolygonOptions(
			contours: [[
				rect.northEastPoint,
				southEastPoint,
				rect.southWestPoint,
				northWestPoint,
			]],
			color: Constants.visibleRectColor
		)
		self.visibleRectPolygon = self.createPolygon(options)
		self.addPolygon(self.visibleRectPolygon)
	}

	func showVisibleArea() {
		guard self.isVisibleAreaShown else {
			if let polygonToRemove = self.visibleAreaPolygon {
				self.mapObjectManager.removeObject(item: polygonToRemove)
				self.visibleAreaPolygon = nil
			}
			return
		}
		let visibleAreaContours = self.getVisibleAreaContours()
		if let contours = visibleAreaContours {
			let options = PolygonOptions(contours: contours, color: Constants.visibleAreaColor)
			self.visibleAreaPolygon = self.createPolygon(options)
			self.addPolygon(self.visibleAreaPolygon)
		}
	}

	private func getVisibleAreaContours() -> [[GeoPoint]]? {
		switch self.map.camera.visibleArea {
		case let polygonGeometry as PolygonGeometry:
			polygonGeometry.contours
		case let complexGeometry as ComplexGeometry:
			complexGeometry.elements.compactMap { $0 as? PolygonGeometry }.first?.contours
		default:
			nil
		}
	}

	private func createPolygon(_ options: PolygonOptions) -> Polygon? {
		do {
			return try Polygon(options: options)
		} catch {
			self.errorMessage = "Failed to create polygon: \(error.localizedDescription)"
			return nil
		}
	}

	private func addPolygon(_ polygon: Polygon?) {
		if let polygonToAdd = polygon {
			self.mapObjectManager.addObject(item: polygonToAdd)
		}
	}
}
