import SwiftUI
import PlatformSDK

final class MarkerViewModel: ObservableObject {

	enum MarkerType: UInt {
		case camera
		case water
		case bridge

		mutating func next() {
			self = MarkerType(rawValue: self.rawValue + 1) ?? .camera
		}

		var text: String {
			switch self {
				case .camera: return "Камера"
				case .water: return "Вода"
				case .bridge: return "Мост"
			}
		}

		var assetName: String {
			switch self {
				case .camera: return "svg_photo"
				case .water: return "svg_water"
				case .bridge: return "svg_bridge"
			}
		}
	}

	enum MarkerSize: UInt {
		case small
		case medium
		case big

		mutating func next() {
			self = MarkerSize(rawValue: self.rawValue + 1) ?? .small
		}

		var text: String {
			switch self {
				case .small: return "маленький"
				case .medium: return "средний"
				case .big: return "большой"
			}
		}

		var size: CGFloat {
			switch self {
				case .small: return 8
				case .medium: return 16
				case .big: return 32
			}
		}

	}

	@Published var type: MarkerType = .camera
	@Published var size: MarkerSize = .small
	@Published private(set) var hasMarkers = false
	
	private let sourceFactory: () -> ISourceFactory
	private let map: Map

	private var hasSource : Bool = false
	private lazy var source = self.sourceFactory().createGeometryMapObjectSource()

	init(
		sourceFactory: @escaping () -> ISourceFactory,
		map: Map
	) {
		self.sourceFactory = sourceFactory
		self.map = map
	}

	func addMarkers(text: String) {
		if !self.hasSource {
			self.map.addSource(source: source)
			self.hasSource = true
		}

		_ = self.map.camera().position().sink { position in

			do {
				let mapObject = try MarkerBuilder()
					.setIcon(svg: NSDataAsset(name: self.type.assetName)!.data)
					.setPosition(point: position.point)
					.setText(text: text)
					.setSize(self.size.size)
					.build()
				self.source.addObject(item: mapObject)
				self.hasMarkers = true
			} catch {
				print("Failed to build text marker. Error: \(error).")
			}

		}
	}

	func removeLast() {
		if let lastAddedMarker = self.source.objects().first {
			self.source.removeObject(item: lastAddedMarker)
		}
		if self.source.objects().count == 0 {
			self.hasMarkers = false
		}
	}
}
