import Combine
import DGis
import SwiftUI

final class RenderedObjectInfoViewModel: ObservableObject {
	typealias CloseCallback = () -> Void

	@Published var title: String = "Map object"
	@Published var description: String

	var objectPosition: GeoPointWithElevation {
		self.objectInfo.closestMapPoint
	}

	private let objectInfo: RenderedObjectInfo
	private let onClose: CloseCallback

	init(
		objectInfo: RenderedObjectInfo,
		onClose: @escaping CloseCallback
	) {
		self.objectInfo = objectInfo
		self.description = objectInfo.description
		self.onClose = onClose
		self.fetchObjectInfo()
	}

	func close() {
		self.onClose()
	}

	private func fetchObjectInfo() {
		let mapObject = self.objectInfo.item.item
		switch mapObject {
		case let circle as DGis.Circle:
			self.fetchInfo(circle: circle)
		case let marker as Marker:
			self.fetchInfo(marker: marker)
		case let polygon as Polygon:
			self.fetchInfo(polygon: polygon)
		case let polyline as Polyline:
			self.fetchInfo(polyline: polyline)
		default:
			self.fetchInfo(objectInfo: self.objectInfo)
		}
	}

	private func fetchInfo(circle: DGis.Circle) {
		self.title = "Circle"
		self.description = """
		\(circle.position)
		Radius: \(circle.radius)
		zIndex: \(circle.zIndex)
		UserData: \(circle.userData)
		"""
	}

	private func fetchInfo(marker: Marker) {
		let text = marker.text
		self.title = text.isEmpty ? "Marker" : text
		self.description = """
		\(marker.position)
		zIndex: \(marker.zIndex)
		UserData: \(marker.userData)
		"""
	}

	private func fetchInfo(polygon: Polygon) {
		self.title = "Polygon"
		self.description = """
		Contours: \(polygon.contours.count)
		zIndex: \(polygon.zIndex)
		UserData: \(polygon.userData)
		"""
	}

	private func fetchInfo(polyline: Polyline) {
		self.title = "Polyline"
		self.description = """
		Points: \(polyline.points.count)
		zIndex: \(polyline.zIndex)
		UserData: \(polyline.userData)
		"""
	}

	private func fetchInfo(objectInfo: RenderedObjectInfo) {
		self.title = String(describing: type(of: objectInfo))
		self.description = String(describing: objectInfo)
	}
}
