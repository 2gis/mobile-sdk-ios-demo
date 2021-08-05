import SwiftUI
import DGis

final class ClusterCardViewModel: ObservableObject {

	typealias CloseCallback = () -> Void

	public let title: String
	public let description: String

	private let onClose: CloseCallback

	init(
		clusterObject: SimpleClusterObject,
		onClose: @escaping CloseCallback
	) {
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
		self.onClose = onClose
	}

	func close() {
		self.onClose()
	}
}
