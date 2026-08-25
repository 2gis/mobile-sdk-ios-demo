import Combine
import DGis
import Foundation
import SwiftUI

final class CacheDemoViewModel: ObservableObject, @unchecked Sendable {
	@Published var combinedCacheSize: String = "0 MB / 300 MB"
	@Published var cacheSize: Double {
		didSet {
			if self.cacheSize != oldValue {
				self.setCacheSize(size: UInt64(self.cacheSize))
				self.updateCurrentCacheSize()
			}
		}
	}

	let byteCountFormatter = ByteCountFormatter()
	private let map: Map
	private let cacheManager: HttpCacheManager
	private var timer: Timer?

	init(
		map: Map,
		cacheManager: HttpCacheManager
	) {
		self.map = map
		self.cacheManager = cacheManager
		self.byteCountFormatter.allowedUnits = [.useKB, .useMB, .useGB]
		self.byteCountFormatter.countStyle = .memory
		self.cacheSize = Double(self.cacheManager.maxSize)
		self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
			self?.updateCurrentCacheSize()
		}
	}

	func clearCache() {
		self.cacheManager.clear()
	}

	private func setCacheSize(size: UInt64) {
		self.cacheManager.maxSize = size
	}

	private func updateCurrentCacheSize() {
		let maxCacheSizeString = self.byteCountFormatter.string(fromByteCount: Int64(self.cacheSize))
		let cacheSizeBytes = self.cacheManager.currentSize
		let currentCacheSizeString = self.byteCountFormatter.string(fromByteCount: Int64(cacheSizeBytes))
		self.combinedCacheSize = "\(currentCacheSizeString) / \(maxCacheSizeString)"
	}
}
