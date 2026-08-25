import Combine
import DGis
import SwiftUI

final class ModelViewModel: ObservableObject {
	enum ModelType: UInt {
		case airplane
		case cubesFly
		case cubesFall

		mutating func next() {
			self = ModelType(rawValue: self.rawValue + 1) ?? .airplane
		}

		var text: String {
			switch self {
			case .airplane: "Airplane"
			case .cubesFly: "Cubes Fly"
			case .cubesFall: "Cubes Fall"
			@unknown default: fatalError("Unknown type: \(self)")
			}
		}

		var modelData: Data? {
			let name = switch self {
			case .airplane: "models/airplane"
			case .cubesFly: "models/cubes_fly"
			case .cubesFall: "models/cubes_fall"
			@unknown default: fatalError("Unknown type: \(self)")
			}
			return NSDataAsset(name: name)?.data
		}
	}

	@Published var type: ModelType = .airplane
	@Published var modelSize: String = "50"
	@Published var scaleEnabled: Bool = false
	@Published var userData: String = ""
	@Published var isErrorAlertShown: Bool = false

	private let map: Map
	private let modelFactory: IModelFactory
	private let logger: ILogger
	private lazy var mapObjectManager = MapObjectManager(map: self.map)
	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	private var modelCache: [ModelType: ModelData] = [:]

	init(
		map: Map,
		modelFactory: IModelFactory,
		logger: ILogger
	) {
		self.map = map
		self.modelFactory = modelFactory
		self.logger = logger
	}

	func addModel() {
		guard let modelData = self.getCachedModelData() else {
			self.errorMessage = "Failed to load model data."
			return
		}
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

	func getCachedModelData() -> ModelData? {
		if let cachedModel = modelCache[self.type] {
			return cachedModel
		}
		guard let data = self.type.modelData else { return nil }
		let model = self.modelFactory.make(modelData: data)
		self.modelCache[self.type] = model
		return model
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

extension ModelViewModel: IMapObjectViewModel {
	func removeAll() {
		self.mapObjectManager.removeAll()
	}
}
