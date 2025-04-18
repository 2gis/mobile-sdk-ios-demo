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
				Text("Нет логов")
			} else {
				ForEach(self.viewModel.logFileURLs, id:\.self) { url in
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
								Text("Поделиться")
								Image(systemName: "square.and.arrow.up")
							}
							.foregroundColor(.blue)
							.contentShape(Rectangle())
							.frame(height: 44)
							.onTapGesture(perform: {
								self.shareLogFile(url)
							})
							HStack {
								Text("Удалить")
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
			title: "Удалалить файл?",
			message: fileURL.lastPathComponent,
			preferredStyle: .alert
		)
		alert.addAction(.init(title: "Отмена", style: .cancel))
		alert.addAction(.init(title: "Удалить", style: .destructive, handler: { _ in
			self.viewModel.deleteLogFile(fileURL)
		}))
		self.navigationService.present(alert, animated: true, completion: nil)
	}
}

private class LogFileDetailsViewModel: ObservableObject {
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
						Text("Читаем файл...")
					case .ready(let content):
						if #available(iOS 15.0, *) {
							Text(content)
							.textSelection(.enabled)
							.font(.system(size: 10))
						} else {
							Text(content)
							.font(.system(size: 10))
						}
					case .error(let error):
						Text("Не удалось прочитать файл: \(error.localizedDescription)")
				}
			}
			.padding(8)
		}
		.navigationBarTitle(self.viewModel.fileName)
	}
}
