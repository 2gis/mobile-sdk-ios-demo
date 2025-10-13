import Combine
import SwiftUI

struct LogFileListView: View {
	@ObservedObject private var viewModel: LogFileListViewModel
	@EnvironmentObject private var navigationService: NavigationService

	init(viewModel: LogFileListViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		List {
			if self.viewModel.logFileURLs.isEmpty {
				Text("No log files found")
			} else {
				ForEach(self.viewModel.logFileURLs, id: \.self) { url in
					VStack(alignment: .leading) {
						HStack {
							Text(url.lastPathComponent)
							Spacer()
							Image(systemName: "chevron.right")
						}
						.onTapGesture(perform: {
							self.showLogFile(url)
						})
						.contentShape(Rectangle())
						.frame(height: 44)
						HStack {
							HStack {
								Text("Share")
								Image(systemName: "square.and.arrow.up")
							}
							.foregroundColor(.blue)
							.contentShape(Rectangle())
							.frame(height: 44)
							.onTapGesture(perform: {
								self.shareLogFile(url)
							})
							HStack {
								Text("Delete")
								Image(systemName: "trash")
							}
							.foregroundColor(.red)
							.frame(height: 44)
							.contentShape(Rectangle())
							.onTapGesture(perform: {
								self.deleteLogFile(url)
							})
						}
					}
				}
			}
		}
	}

	private func showLogFile(_ fileURL: URL) {
		let viewModel = LogFileDetailsViewModel(logFileURL: fileURL)
		self.navigationService.push(LogFileDetailsView(viewModel: viewModel))
	}

	private func shareLogFile(_ fileURL: URL) {
		let activityVC = UIActivityViewController(
			activityItems: [fileURL],
			applicationActivities: nil
		)
		self.navigationService.present(activityVC, animated: true, completion: nil)
	}

	private func deleteLogFile(_ fileURL: URL) {
		let alert = UIAlertController(
			title: "Delete log file?",
			message: fileURL.lastPathComponent,
			preferredStyle: .alert
		)
		alert.addAction(.init(title: "Cancel", style: .cancel))
		alert.addAction(.init(title: "Delete", style: .destructive, handler: { _ in
			self.viewModel.deleteLogFile(fileURL)
		}))
		self.navigationService.present(alert, animated: true, completion: nil)
	}
}

private class LogFileDetailsViewModel: ObservableObject, @unchecked Sendable {
	enum State {
		case loading
		case ready(String)
		case error(Error)
	}

	var fileName: String {
		self.logFileURL.lastPathComponent
	}

	@Published var state: State

	private let logFileURL: URL

	init(logFileURL: URL) {
		self.logFileURL = logFileURL
		self.state = .loading
		self.loadFileContent()
	}

	func loadFileContent() {
		let fileURL = self.logFileURL
		DispatchQueue.global().async { [weak self] in
			let newState: State
			do {
				let content = try String(contentsOf: fileURL)
				newState = .ready(content)
			} catch {
				newState = .error(error)
			}
			DispatchQueue.main.async {
				self?.state = newState
			}
		}
	}
}

private struct LogFileDetailsView: View {
	@ObservedObject private var viewModel: LogFileDetailsViewModel

	init(viewModel: LogFileDetailsViewModel) {
		self.viewModel = viewModel
	}

	var body: some View {
		ScrollView {
			VStack {
				switch self.viewModel.state {
				case .loading:
					Text("Reading file...")
				case let .ready(content):
					Text(content)
						.textSelection(.enabled)
						.font(.system(size: 10))
				case let .error(error):
					Text("Can't read file: \(error.localizedDescription)")
				@unknown default:
					fatalError("Unknown type: \(self.viewModel.state)")
				}
			}
			.padding(8)
		}
		.navigationBarTitle(self.viewModel.fileName)
	}
}
