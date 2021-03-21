import SwiftUI
import PlatformSDK

final class MapObjectCardViewModel: ObservableObject {

	typealias CloseCallback = () -> Void

	@Published var title: String = "Some place"
	@Published var description: String

	private let objectInfo: RenderedObjectInfo
	private let onClose: CloseCallback
	private var getDirectoryObjectCancellable: Cancellable?

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
			case let object as DgisMapObject:
				self.fetchInfo(dgisMapObject: object)
			case let marker as Marker:
				self.fetchInfo(marker: marker)
			default:
				self.fetchInfo(objectInfo: self.objectInfo)
		}
	}

	private func fetchInfo(dgisMapObject object: DgisMapObject) {
		self.getDirectoryObjectCancellable = object.directoryObject.sinkOnMainThread(
			receiveValue: {
				[weak self] directoryObject in
				guard let directoryObject = directoryObject else { return }

				self?.title = directoryObject.title
				self?.description = """
					\(directoryObject.subtitle)
					\(directoryObject.formattedAddress(type: .short)?.streetAddress ?? "(no address)")
					\(directoryObject.markerPosition?.description ?? "(no location)")
					ID: \(object.id.value)
					"""
			},
			failure: { error in
				print("Unable to fetch a directory object. Error: \(error).")
			}
		)
	}

	private func fetchInfo(marker: Marker) {
		let text = marker.text
		self.title = text.isEmpty ? "Marker" : text
		self.description = "\(marker.position)"
	}

	private func fetchInfo(objectInfo: RenderedObjectInfo) {
		self.title = String(describing: type(of: objectInfo))
		self.description = String(describing: objectInfo)
	}
}
