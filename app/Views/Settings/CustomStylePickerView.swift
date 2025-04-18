import SwiftUI
import UniformTypeIdentifiers
import CoreServices

struct CustomStylePickerView: UIViewControllerRepresentable {
	@Binding var fileURL: URL?

	func makeCoordinator() -> CustomStylePickerCoordinator {
		CustomStylePickerCoordinator(fileURL: self.$fileURL)
	}

	func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
		let anyType = kUTTypeItem as String
		let documentPicker = UIDocumentPickerViewController(
			documentTypes: [anyType],
			in: .import
		)

		documentPicker.allowsMultipleSelection = false
		documentPicker.shouldShowFileExtensions = true
		documentPicker.delegate = context.coordinator

		return documentPicker
	}

	func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
	}
}

class CustomStylePickerCoordinator: NSObject, UIDocumentPickerDelegate {
	@Binding var fileURL: URL?

	private lazy var temporaryDirectoryPath = FileManager.default.temporaryDirectory.relativePath

	init(fileURL: Binding<URL?>) {
		self._fileURL = fileURL
	}

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		guard let url = urls.first else { return }
		self.fileURL = url
	}

	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		self.fileURL = nil
	}
}
