import SwiftUI
import PlatformSDK

final class MapObjectCardViewModel: ObservableObject {

	typealias CloseCallback = () -> Void

	private let objectInfo: RenderedObjectInfo
	private let closeCallback: CloseCallback
	private var getDirectoryObjectCancellable: Cancellable?

	var title: String {
		guard let mapObject = self.objectInfo.item.item else {
			return String(describing: type(of: self.objectInfo.item))
		}
		return String(describing: type(of: mapObject))
	}

	@Published var description: String

	init(
		objectInfo: RenderedObjectInfo,
		closeCallback: @escaping CloseCallback
	) {
		self.objectInfo = objectInfo
		self.description = objectInfo.description
		self.closeCallback = closeCallback
		self.fetchObjectInfo()
	}

	func close() {
		self.closeCallback()
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
