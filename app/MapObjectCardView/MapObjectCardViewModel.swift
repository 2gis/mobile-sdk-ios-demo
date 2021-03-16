import SwiftUI
import PlatformSDK

final class MapObjectCardViewModel: ObservableObject {

	typealias CloseCallback = () -> Void

	var title: String {
		let mapObject = self.objectInfo.item.item
		return String(describing: type(of: mapObject))
	}

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
		guard let dgisMapObject = self.objectInfo.item.item as? DgisMapObject else { return }
		self.getDirectoryObjectCancellable = dgisMapObject.directoryObject().sinkOnMainThread(
			receiveValue: {
				[weak self] directoryObject in
				guard let directoryObject = directoryObject else { return }

				self?.description = "Id: \(dgisMapObject.id().value)\nTitle: \(directoryObject.title())"
			},
			failure: { error in
				print("Unable to fetch directoryObject. Error: \(error).")
			}
		)
	}
}
