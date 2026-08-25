import Combine
import DGis
import SwiftUI

final class ClusterCardViewModel: ObservableObject {
	typealias CloseCallback = () -> Void

	public var title: String = ""
	public var description: String = ""

	private let onClose: CloseCallback

	init(
		mapObject: MapObject,
		onClose: @escaping CloseCallback
	) {
		self.onClose = onClose
		self.setupObjectInfo(mapObject: mapObject)
	}

	func close() {
		self.onClose()
	}

	private func setupObjectInfo(mapObject: MapObject) {
		switch mapObject {
		case let cluster as SimpleClusterObject:
			self.setupClusterInfo(clusterObject: cluster)
			return
		case let marker as Marker:
			self.setupMarkerInfo(markerObject: marker)
			return
		default:
			return
		}
	}

	private func setupClusterInfo(clusterObject: SimpleClusterObject) {
		self.title = "Cluster with \(clusterObject.objectCount) objects"
		self.description = """
		Anchor: [\(clusterObject.anchor.x) \(clusterObject.anchor.y)]
		Opacity: \(clusterObject.iconOpacity.value)
		Text: \(clusterObject.text)
		IconWidth: \(clusterObject.iconWidth.value)
		IconMapDirection: \(String(describing: clusterObject.iconMapDirection?.value))
		AnimatedAppearance: \(clusterObject.animatedAppearance)
		zIndex: \(clusterObject.zIndex.value)
		"""
	}

	private func setupMarkerInfo(markerObject: Marker) {
		self.title = "Marker \(markerObject.userData)"
		self.description = """
		Anchor: [\(markerObject.anchor.x) \(markerObject.anchor.y)]
		Opacity: \(markerObject.iconOpacity.value)
		Text: \(markerObject.text)
		IconWidth: \(markerObject.iconWidth.value)
		IconMapDirection: \(String(describing: markerObject.iconMapDirection?.value))
		AnimatedAppearance: \(markerObject.animatedAppearance)
		zIndex: \(markerObject.zIndex.value)
		"""
	}
}
