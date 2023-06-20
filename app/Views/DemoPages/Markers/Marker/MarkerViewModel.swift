import SwiftUI
import DGis

final class MarkerViewModel: ObservableObject {

	enum ImageOrData {
		case image(UIImage?)
		case data(Data?)
	}

	enum MarkerType: UInt {
		case camera
		case water
		case shelter
		case droneLottie
		case batLottie

		mutating func next() {
			self = MarkerType(rawValue: self.rawValue + 1) ?? .camera
		}

		var text: String {
			switch self {
				case .camera: return "Camera"
				case .water: return "Water"
				case .shelter: return "Shelter"
				case .droneLottie: return "Animated drone"
				case .batLottie: return "Animated bat"
			}
		}

		var imageData: ImageOrData {
			switch self {
				case .camera:
					return .image(UIImage(systemName: "camera.fill")?
						.withTintColor(.systemGray))
				case .water:
					return .image(UIImage(systemName: "drop.fill")?
						.withTintColor(.systemTeal))
				case .shelter:
					return .image(UIImage(systemName: "umbrella.fill")?
						.withTintColor(.systemRed))
				case .droneLottie:
					return .data(NSDataAsset(name: "Drone")?.data)
				case .batLottie:
					return .data(NSDataAsset(name: "Bat")?.data)
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
				case .small: return "small"
				case .medium: return "medium"
				case .big: return "big"
			}
		}

		var pixel: DGis.LogicalPixel {
			switch self {
				case .small: return .init(value: 20)
				case .medium: return .init(value: 60)
				case .big: return .init(value: 120)
			}
		}
	}

	private static let tapRadius: CGFloat = 5

	private let toMap: CGAffineTransform = {
		let scale = UIScreen.main.nativeScale
		return CGAffineTransform(scaleX: scale, y: scale)
	}()

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
	private var cancellable: ICancellable = NoopCancellable()

	private var icons: [TypeSize: DGis.Image] = [:]

	init(
		map: Map,
		imageFactory: IImageFactory
	) {
		self.map = map
		self.imageFactory = imageFactory
	}

	func tap(_ location: CGPoint) {
		let mapLocation = location.applying(self.toMap)
		let tapPoint = ScreenPoint(x: Float(mapLocation.x), y: Float(mapLocation.y))
		let tapRadius = ScreenDistance(value: Float(Self.tapRadius))
		self.cancellable = self.map.getRenderedObjects(centerPoint: tapPoint, radius: tapRadius)
			.sink(receiveValue: { infos in
				for info in infos {
					let object = info.item.item
					if let label = object.userData as? String {
						print("Marker label: \(label). Info: \(object)")
					}
				}
			},
			failure: { error in
				print("Failed to fetch objects: \(error)")
			})
	}

	func addMarker(text: String) {
		let flatPoint = self.map.camera.position.point
		let point = GeoPointWithElevation(
			latitude: flatPoint.latitude,
			longitude: flatPoint.longitude
		)
		let icon = self.makeIcon()

		let options = MarkerOptions(
			position: point,
			icon: icon,
			text: text,
			iconWidth: self.size.pixel
		)
		let marker = Marker(options: options)
		self.mapObjectManager.addObject(item: marker)
		self.hasMarkers = true
	}

	func removeAll() {
		self.mapObjectManager.removeAll()
	}

	private func makeIcon() -> DGis.Image? {
		let typeSize = TypeSize(type: self.type, size: self.size)
		if let icon = self.icons[typeSize] {
			return icon
		}

		let icon: DGis.Image?
		switch self.type.imageData {
			case .image(let image):
				icon = image.map { self.imageFactory.make(image: $0) }
			case .data(let data):
				icon = data.map { self.imageFactory.make(lottieData: $0, size: .zero) }
		}

		self.icons[typeSize] = icon
		return icon
	}
}
