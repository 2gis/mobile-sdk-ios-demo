import Combine
import DGis
import SwiftUI

final class MapObjectCardViewModel: ObservableObject, @unchecked Sendable {
	typealias CloseCallback = () -> Void

	@Published var title: String = "Some place" {
		didSet {
			self.titleChangedCallback?(self.title, self.subtitle)
		}
	}

	@Published var description: String

	var objectPosition: GeoPointWithElevation {
		self.objectInfo.closestMapPoint
	}

	var titleChangedCallback: ((String, String) -> Void)?

	private let objectInfo: RenderedObjectInfo
	private let searchManager: SearchManager
	private let logger: ILogger
	private let onClose: CloseCallback
	private var getDirectoryObjectCancellable: ICancellable?
	private var subtitle: String = ""

	init(
		objectInfo: RenderedObjectInfo,
		searchManager: SearchManager,
		logger: ILogger,
		onClose: @escaping CloseCallback
	) {
		self.objectInfo = objectInfo
		self.searchManager = searchManager
		self.logger = logger
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
		let future = self.searchManager.searchByDirectoryObjectId(objectId: object.id)

		self.getDirectoryObjectCancellable = future.sinkOnMainThread(
			receiveValue: {
				[weak self] directoryObject in
				guard let self else { return }
				guard let directoryObject else { return }

				self.subtitle = directoryObject.subtitle
				self.title = directoryObject.title
				self.description = """
				\(directoryObject.subtitle)
				\(directoryObject.formattedAddress(type: .short)?.streetAddress ?? "(no address)")
				\(directoryObject.markerPosition?.description ?? "(no location)")
				ID: \(object.id.objectId)
				FiasCode: \(directoryObject.address?.fiasCode ?? "")
				"""
			},
			failure: { [weak self] error in
				self?.logger.error("Unable to fetch a directory object. Error: \(error).")
			}
		)
	}

	private func fetchInfo(marker: Marker) {
		let text = marker.text
		self.subtitle = "\(marker.position)"
		self.title = text.isEmpty ? "Marker" : text
		self.description = "\(marker.position)"
	}

	private func fetchInfo(objectInfo: RenderedObjectInfo) {
		self.title = String(describing: type(of: objectInfo))
		self.description = String(describing: objectInfo)
	}
}
