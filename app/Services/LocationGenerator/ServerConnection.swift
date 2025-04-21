import Foundation
import Network

final class ServerConnection {
	let connection: NWConnection
	let id: Int

	var didStop: ((Error?) -> Void)?
	var didReceiveData: ((Data) -> Void)?

	private static var nextID: Int = 0
	private let queue: DispatchQueue
	private let logger: ILogger

	init(nwConnection: NWConnection, queue: DispatchQueue, logger: ILogger) {
		self.connection = nwConnection
		self.queue = queue
		self.logger = logger
		self.id = ServerConnection.nextID
		ServerConnection.nextID += 1
	}

	func start() {
		self.connection.stateUpdateHandler = { [weak self] state in
			self?.stateDidChange(to: state)
		}
		self.setupReceive()
		self.connection.start(queue: self.queue)
	}

	func stop() {
		self.didReceiveData = nil
		self.didStop = nil
	}

	private func stateDidChange(to state: NWConnection.State) {
		switch state {
			case .ready:
				break
			case .waiting(let error):
				self.connectionDidFail(error: error)
			case .failed(let error):
				self.connectionDidFail(error: error)
			default:
				break
		}
	}

	private func setupReceive() {
		self.connection.receiveMessage(completion: {
			[weak self] data, _, isComplete, error in
			guard let self = self else { return }
			if let data = data, !data.isEmpty, let didReceiveData = self.didReceiveData {
				didReceiveData(data)
			}
			if isComplete {
				self.connectionDidEnd()
			} else if let error = error {
				self.connectionDidFail(error: error)
			} else {
				self.setupReceive()
			}
		})
	}

	private func connectionDidFail(error: Error) {
		self.logger.error(
			"[ServerConnection] Connection \(self.id) did fail with error: \(error.localizedDescription)."
		)
		self.stop(error: error)
	}

	private func connectionDidEnd() {
		self.stop(error: nil)
	}

	private func stop(error: Error?) {
		self.connection.stateUpdateHandler = nil
		self.connection.cancel()
		if let didStop = self.didStop {
			self.didReceiveData = nil
			self.didStop = nil
			didStop(error)
		}
	}
}
