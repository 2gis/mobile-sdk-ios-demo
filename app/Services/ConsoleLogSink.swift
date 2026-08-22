import DGis

final class ConsoleLogSink: LogSink {
	private nonisolated(unsafe) let logger: ILogger

	init(logger: ILogger) {
		self.logger = logger
	}

	nonisolated func write(message: LogMessage) {
		guard let level = LogLevel(dgisLogLevel: message.level) else { return }
		self.logger.log(
			message.text,
			level: level,
			file: message.file,
			function: "",
			line: Int(message.line)
		)
	}
}

private extension LogLevel {
	nonisolated init?(dgisLogLevel: DGis.LogLevel) {
		switch dgisLogLevel {
		case .verbose:
			self = .verbose
		case .info:
			self = .info
		case .warning:
			self = .warning
		case .error:
			self = .error
		case .fatal:
			self = .fault
		case .off:
			return nil
		@unknown default:
			assertionFailure("Unsupported log level: \(dgisLogLevel)")
			return nil
		}
	}
}
