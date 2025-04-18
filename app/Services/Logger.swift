import Foundation
import SwiftyBeaver
import DGis

enum LogLevel {
	case verbose, info, warning, error, fault
}

protocol ILogger {
	var logFileURL: URL? { get }
	var logFilesFolderURL: URL? { get }

	func log(
		_ message: String,
		level: LogLevel,
		file: String,
		function: String,
		line: Int
	)
}

extension ILogger {
	func log(
		_ message: String,
		level: LogLevel,
		file: String = #file,
		function: String = #function,
		line: Int = #line
	) {
		self.log(message, level: level, file: file, function: function, line: line)
	}

	func verbose(
		_ message: String,
		file: String = #file,
		function: String = #function,
		line: Int = #line
	) {
		self.log(message, level: .verbose, file: file, function: function, line: line)
	}

	func info(
		_ message: String,
		file: String = #file,
		function: String = #function,
		line: Int = #line
	) {
		self.log(message, level: .info, file: file, function: function, line: line)
	}

	func warning(
		_ message: String,
		file: String = #file,
		function: String = #function,
		line: Int = #line
	) {
		self.log(message, level: .warning, file: file, function: function, line: line)
	}

	func error(
		_ message: String,
		file: String = #file,
		function: String = #function,
		line: Int = #line
	) {
		self.log(message, level: .error, file: file, function: function, line: line)
	}

	func fault(
		_ message: String,
		file: String = #file,
		function: String = #function,
		line: Int = #line
	) {
		self.log(message, level: .fault, file: file, function: function, line: line)
	}
}

final class Logger: ILogger {
	private enum Constants {
		static let logMessageFormat: String = "$Dyyyy-MM-dd HH:mm:ss.SSSZ$d $M"
		static let logFileDateFormat: String = "yyyy-MM-dd-HH-mm-ss-sss"
	}

	let logFileURL: URL?
	let logFilesFolderURL: URL?
	
	private let log = SwiftyBeaver.self

	init() {
		var logFileURL: URL?
		let formatter = DateFormatter()
		formatter.dateFormat = Constants.logFileDateFormat
		if let url = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first {
			logFileURL = url.appendingPathComponent("logs/\(formatter.string(from: Date())).log")
		}
		let fileDestination = FileDestination(logFileURL: logFileURL)
		fileDestination.format = Constants.logMessageFormat
		self.log.addDestination(fileDestination)
		self.logFileURL = fileDestination.logFileURL
		self.logFilesFolderURL = fileDestination.logFileURL?.deletingLastPathComponent()
	}

	func log(
		_ message: String,
		level: LogLevel,
		file: String,
		function: String,
		line: Int
	) {
		self.log.custom(
			level: .debug,
			message: "\(self.makeLevelString(level)) \(file):\(line) - \(message)"
		)
	}

	private func makeLevelString(_ level: LogLevel) -> String {
		switch level {
			case .verbose:
				return "VERBOSE"
			case .info:
				return "INFO"
			case .warning:
				return "WARNING"
			case .error:
				return "ERROR"
			case .fault:
				return "FATAL"
		}
	}
}
