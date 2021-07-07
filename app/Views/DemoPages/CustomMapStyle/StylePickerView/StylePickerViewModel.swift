import SwiftUI
import Combine
import DGis

final class StylePickerViewModel: ObservableObject {
	/// URL to a selected style URL. Must be a file URL.
	@Published var styleFileURL: URL?

	private let styleFactory: () -> IStyleFactory
	private let map: Map
	private var cancellables: [Combine.AnyCancellable] = []
	private var loadStyleCancellable: DGis.Cancellable?

	init(
		styleFactory: @escaping () -> IStyleFactory,
		map: Map
	) {
		self.styleFactory = styleFactory
		self.map = map

		self.$styleFileURL.sink(receiveValue: {
			[weak self] styleURLOpt in
				self?.updateStyle(fileURL: styleURLOpt)
			})
			.store(in: &self.cancellables)
	}

	private func updateStyle(fileURL: URL?) {
		guard let fileURL = fileURL else { return }

		assert(fileURL.isFileURL)

		let factory = styleFactory()
		let styleFuture = factory.loadFile(url: fileURL)
		self.loadStyleCancellable = styleFuture.sink(
			receiveValue: { [map = self.map] style in
				map.setStyle(style: style)
			},
			failure: { error in
				print("Failed to load style from <\(fileURL)>. Error: \(error)")
			})
	}
}
