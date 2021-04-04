import SwiftUI
import CoreServices

struct StylePickerView: UIViewControllerRepresentable {
	@Binding var fileURL: URL?

	func makeCoordinator() -> StylePickerCoordinator {
		StylePickerCoordinator(fileURL: self.$fileURL)
	}

	func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
		// Allow to pick *any* file.
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

class StylePickerCoordinator: NSObject, UIDocumentPickerDelegate {
	@Binding var fileURL: URL?

	init(fileURL: Binding<URL?>) {
		self._fileURL = fileURL
	}

	func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
		self.fileURL = urls.first
	}

	func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
		self.fileURL = nil
	}
}
