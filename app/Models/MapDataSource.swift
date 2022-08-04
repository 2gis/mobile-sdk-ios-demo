import Foundation 

enum MapDataSource: String, CaseIterable {
	case online, hybrid, offline
}

extension MapDataSource {
	static let `default`: MapDataSource = {
		return .hybrid
	}()

	var name: String {
		switch self {
			case .online:
				return "Online"
			case .offline:
				return "Offline"
			case .hybrid:
				return "Hybrid"
		}
	}
}
