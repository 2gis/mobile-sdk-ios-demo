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
		case text
		case emptyObject
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
				case .text: return "Text object"
				case .emptyObject: return "Empty object"
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
				case .text:
					return .image(nil)
				case .emptyObject:
					return .image(UIImage())
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
				case .small: return "Small"
				case .medium: return "Medium"
				case .big: return "Big"
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
	@Published var animationMode: AnimationMode = .normal
	@Published var markerText: String = ""
	@Published var zIndex: String = "0"
	@Published var userData: String = ""
	@Published var isErrorAlertShown: Bool = false

	private let map: Map
	private let imageFactory: IImageFactory
	private lazy var mapObjectManager = MapObjectManager(map: self.map)
	private var cancellable: ICancellable = NoopCancellable()
	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	private var icons: [TypeSize: DGis.Image] = [:]

	init(
		map: Map,
		imageFactory: IImageFactory
	) {
		self.map = map
		self.imageFactory = imageFactory
	}

	func addMarker() {
		let flatPoint = self.map.camera.position.point
		let point = GeoPointWithElevation(
			latitude: flatPoint.latitude,
			longitude: flatPoint.longitude
		)
		let icon = self.makeIcon()
		let indexValue = UInt32(self.zIndex) ?? 0

		let options = MarkerOptions(
			position: point,
			icon: icon,
			text: self.markerText,
			iconWidth: self.size.pixel,
			userData: self.userData,
			zIndex: .init(value: indexValue),
			iconAnimationMode: self.animationMode
		)
		do {
			let marker = try Marker(options: options)
			self.mapObjectManager.addObject(item: marker)
		} catch let error as SimpleError {
			self.errorMessage = error.description
		} catch {
			self.errorMessage = error.localizedDescription
		}
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

extension MarkerViewModel: IMapObjectViewModel {
	func removeAll() {
		self.mapObjectManager.removeAll()
	}
}

extension AnimationMode {
	mutating func next() {
		self = AnimationMode(rawValue: self.rawValue + 1) ?? .normal
	}

	var text: String {
		switch self {
			case .normal: return "Normal"
			case .loop: return "Loop"
		}
	}
}
