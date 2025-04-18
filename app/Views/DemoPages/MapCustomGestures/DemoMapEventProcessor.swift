import DGis
import Foundation

class DemoMapEventProcessor: IMapEventProcessor {
	private let processor: IMapEventProcessor

	init(processor: IMapEventProcessor) {
		self.processor = processor
	}

	func process(event: DGis.Event) {
		self.logProcess(event: event)
	}

	private func logProcess(event: DGis.Event) {
		let eventType = String(describing: type(of: event))
		let timestamp = Date().timeIntervalSince1970
		debugPrint("[Debug] DemoMapEventProcessor: \(eventType), timestamp: \(timestamp)")
		self.processor.process(event: event)
	}
}
