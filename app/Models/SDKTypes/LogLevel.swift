import Foundation
import DGis

extension DGis.LogLevel {
	static var availableLevels: [DGis.LogLevel] {
		[.off, .verbose, .info, .warning, .error, .fatal]
	}
}
