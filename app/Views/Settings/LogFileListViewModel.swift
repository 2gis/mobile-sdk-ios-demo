import Foundation
import Combine

class LogFileListViewModel: ObservableObject {
	@Published private(set) var logFileURLs: [URL]

	private let logger: ILogger

	init(logger: ILogger) {
		self.logger = logger
		if let url = logger.logFilesFolderURL {
			do {
				let fileManager = FileManager.default
				self.logFileURLs = try fileManager.contentsOfDirectory(
					at: url,
					includingPropertiesForKeys: nil,
					options: .skipsSubdirectoryDescendants
				).compactMap {
					if $0.isFileURL, $0.pathExtension == "log" || $0.pathExtension == "csv" {
						return $0
					} else {
						return nil
					}
				}.sorted(by: { $0.lastPathComponent > $1.lastPathComponent })
			} catch {
				logger.error("Unable to read folder content \(url). Reason: \(error.localizedDescription)")
				self.logFileURLs = []
			}
		} else {
			self.logFileURLs = []
		}
	}

	func deleteLogFile(_ fileURL: URL) {
		guard let fileIndex = self.logFileURLs.firstIndex(of: fileURL) else { return }
		do {
			let fileManager = FileManager.default
			try fileManager.removeItem(at: fileURL)
			self.logFileURLs.remove(at: fileIndex)
		} catch {
			self.logger.error("Unable to delete log file \(fileURL.path) reason: \(error.localizedDescription)")
		}
	}
}
