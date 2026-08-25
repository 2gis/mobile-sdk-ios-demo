import Combine
import DGis
import SwiftUI

final class PolylineViewModel: ObservableObject {
	private enum Constants {
		static let bearingMax = 360.0
	}

	@Published var pointsCount: String = ""
	@Published var zIndex: String = "0"
	@Published var userData: String = ""
	@Published var polylineWidth: StrokeWidth = .thin
	@Published var polylineColor: MapObjectColor = .transparent
	@Published var polylineType: PolylineFillType = .solid
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

	func addPolyline() {
		let points = self.makePoints()
		var gradientOptions: GradientPolylineOptions? = nil
		if self.polylineType.gradientOptions != nil {
			gradientOptions = self.polylineType.gradientOptions.map { GradientPolylineOptions(
				borderWidth: $0.borderWidth,
				secondBorderWidth: $0.secondBorderWidth,
				gradientLength: $0.gradientLength,
				borderColor: $0.borderColor,
				secondBorderColor: $0.secondBorderColor,
				colors: $0.colors,
				colorIndices: self.adjustedData(base: [0, 1, 2, 3, 4], length: points.count - 1)
			) }
		}
		let indexValue = UInt32(self.zIndex) ?? 0
		let options = PolylineOptions(
			points: points,
			width: self.polylineWidth.pixel,
			color: self.polylineColor.value,
			dashedPolylineOptions: self.polylineType.dashedOptions,
			gradientPolylineOptions: gradientOptions,
			userData: self.userData,
			zIndex: .init(value: indexValue)
		)
		do {
			let polyline = try Polyline(options: options)
			self.mapObjectManager.addObject(item: polyline)
		} catch let error as SimpleError {
			self.errorMessage = error.description
		} catch {
			self.errorMessage = error.localizedDescription
		}
	}

	private func makePoints() -> [GeoPoint] {
		let flatPoint = self.map.camera.position.point
		guard
			let size = Int(self.pointsCount),
			size > 0
		else {
			return []
		}
		let angle = Constants.bearingMax / Double(size)

		return (1 ... size).map { item in
			flatPoint.move(
				bearing: Bearing(value: angle * Double(item)),
				meter: .init(value: Float.random(in: 50000.0 ... 100000.0))
			)
		}
	}

	private func adjustedData(base: [UInt8], length: Int) -> Data {
		var result = [UInt8]()
		while result.count < length {
			result.append(contentsOf: base)
		}
		result = Array(result.prefix(length))
		return Data(result)
	}
}

extension PolylineViewModel: IMapObjectViewModel {
	func removeAll() {
		self.mapObjectManager.removeAll()
	}
}
