import SwiftUI
import DGis

final class MarkerViewModel: ObservableObject {

	enum MarkerType: UInt {
		case camera
		case water
		case shelter

		mutating func next() {
			self = MarkerType(rawValue: self.rawValue + 1) ?? .camera
		}

		var text: String {
			switch self {
				case .camera: return "Camera"
				case .water: return "Water"
				case .shelter: return "Shelter"
			}
		}

		var image: UIImage? {
			switch self {
				case .camera:
					return UIImage(systemName: "camera.fill")?
						.withTintColor(.systemGray)
				case .water:
					return UIImage(systemName: "drop.fill")?
						.withTintColor(.systemTeal)
				case .shelter:
					return UIImage(systemName: "umbrella.fill")?
						.withTintColor(.systemRed)
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
				case .small: return "Small"
				case .medium: return "Medium"
				case .big: return "Big"
			}
		}

		var scale: UIImage.SymbolScale {
			switch self {
				case .small: return .small
				case .medium: return .medium
				case .big: return .large
			}
		}

	}

	private struct TypeSize: Hashable {
		let type: MarkerType
		let size: MarkerSize
	}

	@Published var type: MarkerType = .camera
	@Published var size: MarkerSize = .small
	@Published private(set) var hasMarkers = false

	private let map: Map
	private let imageFactory: IImageFactory
	private lazy var mapObjectManager: MapObjectManager =
		MapObjectManager(map: self.map)

	private var icons: [TypeSize: DGis.Image] = [:]

	init(
		map: Map,
		imageFactory: IImageFactory
	) {
		self.map = map
		self.imageFactory = imageFactory
	}

	func addMarkers(text: String) {
		let flatPoint = self.map.camera.position.point
		let point = GeoPointWithElevation(
			latitude: flatPoint.latitude,
			longitude: flatPoint.longitude
		)
		let icon = self.makeIcon(type: self.type, size: self.size)

		let options = MarkerOptions(
			position: point,
			icon: icon,
			text: text
		)
		let marker = Marker(options: options)
		self.mapObjectManager.addObject(item: marker)
		self.hasMarkers = true
	}

	func removeAll() {
		self.mapObjectManager.removeAll()
	}

	private func makeIcon(type: MarkerType, size: MarkerSize) -> DGis.Image? {
		let typeSize = TypeSize(type: type, size: size)
		if let icon = self.icons[typeSize] {
			return icon
		} else if let image = type.image,
			let scaledImage = image.applyingSymbolConfiguration(.init(scale: size.scale)) {
			let icon = self.imageFactory.make(image: scaledImage)
			self.icons[typeSize] = icon
			return icon
		} else {
			return nil
		}
	}
}
