import SwiftUI
import PlatformSDK

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
				case .camera: return "Камера"
				case .water: return "Вода"
				case .shelter: return "Укрытие"
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
				case .small: return "маленький"
				case .medium: return "средний"
				case .big: return "большой"
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
	
	private let imageFactory: IImageFactory
	private let map: Map
	private lazy var objectManager: MapObjectManager =
		createMapObjectManager(map: self.map)

	private var icons: [TypeSize: PlatformSDK.Image] = [:]

	init(
		imageFactory: IImageFactory,
		map: Map
	) {
		self.imageFactory = imageFactory
		self.map = map
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

		_ = self.objectManager.addMarker(options: options)

		self.hasMarkers = true
	}

	func removeAll() {
		self.objectManager.removeAll()
	}

	private func makeIcon(type: MarkerType, size: MarkerSize) -> PlatformSDK.Image? {
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
