import Combine
import CoreLocation
import Foundation
import Network

protocol ILocationGeneratorReceiver {
	/// Последние данные о местоположении.
	var locations: CurrentValueSubject<[CLLocation], Never> { get }

	/// Создать соединение на прослушивание.
	@MainActor
	func connect()
	/// Удалить соединение.
	@MainActor
	func disconnect()
}

final class LocationGeneratorReceiver: NSObject, ILocationGeneratorReceiver, @unchecked Sendable {
	var locations: CurrentValueSubject<[CLLocation], Never> = .init([])

	private let logger: ILogger
	private let port: UInt16
	private var listener: NWListener?
	private var connections = [Int: ServerConnection]()
	private var postponedData: Data?
	private let queue: DispatchQueue

	init(port: UInt16, queue: DispatchQueue, logger: ILogger) {
		self.port = port
		self.queue = queue
		self.logger = logger
		super.init()
	}

	deinit {
		MainActor.assumeIsolated { [self] in
			self.disconnect()
		}
	}

	func connect() {
		self.logger.info("[LocationGeneratorReceiver] Server starting...")
		self.listener = self.createListener()
		self.listener?.start(queue: .main)
	}

	func disconnect() {
		self.listener?.stateUpdateHandler = nil
		self.listener?.newConnectionHandler = nil
		self.listener?.cancel()
		for connection in self.connections.values {
			connection.stop()
		}
		self.connections.removeAll()
		self.locations.value.removeAll()
	}

	@MainActor
	private func createListener() -> NWListener? {
		guard let port = NWEndpoint.Port(rawValue: self.port),
		      let listener = try? NWListener(using: .udp, on: port)
		else {
			self.logger.info("[LocationGeneratorReceiver] Unable to create server listener.")
			return nil
		}

		listener.stateUpdateHandler = { [weak self] state in
			self?.stateDidChange(to: state)
		}
		listener.newConnectionHandler = { [weak self] connection in
			Task { @MainActor [weak self] in
				self?.didAccept(nwConnection: connection)
			}
		}
		return listener
	}

	private func stateDidChange(to state: NWListener.State) {
		switch state {
		case .ready:
			self.logger.info("[LocationGeneratorReceiver] Server ready.")
		case let .failed(error):
			self.logger.error(
				"[LocationGeneratorReceiver] Server failure, error: \(error.localizedDescription)."
			)
		default:
			break
		}
	}

	@MainActor
	private func didAccept(nwConnection: NWConnection) {
		let connection = ServerConnection(nwConnection: nwConnection, queue: self.queue, logger: self.logger)
		self.connections[connection.id] = connection
		connection.didStop = {
			[weak self] _ in
			self?.connections.removeValue(forKey: connection.id)
		}
		connection.didReceiveData = {
			[weak self] data in
			if let locations = self?.proccessData(data: data), locations.count > 0 {
				self?.locations.value = locations
			}
		}
		connection.start()
	}

	private func proccessData(data: Data) -> [CLLocation] {
		let data: Data = {
			guard var postponedData = self.postponedData else { return data }
			postponedData.append(data)
			return postponedData
		}()

		let string = String(data: data, encoding: .utf8)
		var locations: [CLLocation] = []
		if let string {
			var gpsDataStrings = string.split(separator: "|")
			if string.last != "|", let last = gpsDataStrings.last {
				gpsDataStrings.removeLast()
				if let data = last.data(using: .utf8) {
					self.postponedData = data
				}
			}
			for gpsDataString in gpsDataStrings {
				guard let data = gpsDataString.data(using: .utf8) else { continue }
				let gpsData: GpsData? = {
					do {
						let decoder = JSONDecoder()
						return try decoder.decode(GpsData.self, from: data)
					} catch {
						self.logger.error(
							"[LocationGeneratorReceiver] Error parse gps data \(error.localizedDescription)."
						)
						return nil
					}
				}()
				if let gpsData {
					locations.append(CLLocation(gpsData: gpsData))
				}
			}
		}
		return locations
	}
}

private struct GpsData: Decodable {
	struct GpsDataCoordinate: Decodable {
		public let longitude: Double
		public let latitude: Double
	}

	let point: GpsDataCoordinate
	let accuracy: Double
	let speed: Double?
	let course: Double?
}

private extension CLLocation {
	convenience init(gpsData: GpsData) {
		let coordinate = CLLocationCoordinate2D(
			latitude: gpsData.point.latitude,
			longitude: gpsData.point.longitude
		)

		self.init(
			coordinate: coordinate,
			altitude: 0,
			horizontalAccuracy: gpsData.accuracy,
			verticalAccuracy: 0,
			course: gpsData.course ?? 0,
			courseAccuracy: 1,
			speed: gpsData.speed ?? 0,
			speedAccuracy: 1,
			timestamp: Date()
		)
	}
}
