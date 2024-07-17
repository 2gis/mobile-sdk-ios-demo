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
	@Published var isErrorAlertShown: Bool = false

	private let map: Map
	private let mapObjectManager: MapObjectManager
	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	init(
		map: Map,
		mapObjectManager: MapObjectManager
	) {
		self.map = map
		self.mapObjectManager = mapObjectManager
	}

	func addCircle() {
		let radius = Float(self.circleRadius) ?? Constants.defaultRadius
		let options = CircleOptions(
			position: self.map.camera.position.point,
			radius: .init(value: radius),
			color: self.circleColor.value,
			strokeWidth: self.strokeWidth.pixel,
			strokeColor: self.strokeColor.value,
			dashedStrokeOptions: self.strokeType.dashedOptions
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
