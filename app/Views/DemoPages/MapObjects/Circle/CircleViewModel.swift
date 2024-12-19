import SwiftUI
import DGis

final class CircleViewModel: ObservableObject {
	private enum Constants {
		static let defaultRadius: Float = 5.0
	}

	@Published var circleColor: MapObjectColor = .transparent
	@Published var circleRadius: String = ""
	@Published var strokeWidth: StrokeWidth = .thin
	@Published var strokeColor: MapObjectColor = .transparent
	@Published var strokeType: CircleStrokeType = .solid
	@Published var zIndex: String = "0"
	@Published var userData: String = ""
	@Published var isErrorAlertShown: Bool = false

	private let map: Map
	private lazy var mapObjectManager = MapObjectManager(map: self.map)
	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	init(
		map: Map
	) {
		self.map = map
	}

	func addCircle() {
		let radius = Float(self.circleRadius) ?? Constants.defaultRadius
		let indexValue = UInt32(self.zIndex) ?? 0
		let options = CircleOptions(
			position: self.map.camera.position.point,
			radius: .init(value: radius),
			color: self.circleColor.value,
			strokeWidth: self.strokeWidth.pixel,
			strokeColor: self.strokeColor.value,
			dashedStrokeOptions: self.strokeType.dashedOptions,
			userData: self.userData,
			zIndex: .init(value: indexValue)
		)
		do {
			let circle = try Circle(options: options)
			self.mapObjectManager.addObject(item: circle)
		} catch let error as SimpleError {
			self.errorMessage = error.description
		} catch {
			self.errorMessage = error.localizedDescription
		}
	}
}

extension CircleViewModel: IMapObjectViewModel {
	func removeAll() {
		self.mapObjectManager.removeAll()
	}
}
