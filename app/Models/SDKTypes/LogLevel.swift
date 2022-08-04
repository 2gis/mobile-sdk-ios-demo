import Foundation
import DGis

extension DGis.LogLevel {
	static var availableLevels: [DGis.LogLevel] {
		[.disabled, .verbose, .info, .warning, .error, .fault]
	}
}
