import SwiftUI
import DGis

final class ModelViewModel: ObservableObject {
	enum ModelType: UInt {
		case cubesFly
		case cubesFall

		mutating func next() {
			self = ModelType(rawValue: self.rawValue + 1) ?? .cubesFly
		}

		var text: String {
			switch self {
			case .cubesFly: return "Cubes Fly"
			case .cubesFall: return "Cubes Fall"
			}
		}

		var modelData: Data? {
			var name: String
			switch self {
				case .cubesFly:
					name = "cubes_fly"
				case .cubesFall:
					name = "cubes_fall"
			}
			return NSDataAsset(name: name)?.data
		}
	}

	@Published var type: ModelType = .cubesFly
	@Published var modelSize: String = "0"
	@Published var scaleEnabled: Bool = false
	@Published var userData: String = ""
	@Published var isErrorAlertShown: Bool = false

	private let map: Map
	private let modelFactory: IModelFactory
	private lazy var mapObjectManager = MapObjectManager(map: self.map)
	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	init(
		map: Map,
		modelFactory: IModelFactory
	) {
		self.map = map
		self.modelFactory = modelFactory
	}

	func addModel() {
		let modelData = self.type.modelData.map { self.modelFactory.make(modelData: $0) }
		let flatPoint = self.map.camera.position.point
		let point = GeoPointWithElevation(
			latitude: flatPoint.latitude,
			longitude: flatPoint.longitude
		)

		let modelSize = self.makeModelSize()

		let options = ModelMapObjectOptions(
			position: point,
			data: modelData,
			size: modelSize,
			userData: self.userData
		)
		do {
			let model = try ModelMapObject(options: options)
			self.mapObjectManager.addObject(item: model)
		} catch let error as SimpleError {
			self.errorMessage = error.description
		} catch {
			self.errorMessage = error.localizedDescription
		}
	}

	private func makeModelSize() -> DGis.ModelSize {
		let modelSizeValue = Float(self.modelSize) ?? 0
		if self.scaleEnabled {
			return DGis.ModelSize.scale(.init(value: modelSizeValue))
		} else {
			return DGis.ModelSize.logicalPixel(.init(value: modelSizeValue))
		}
	}
}
