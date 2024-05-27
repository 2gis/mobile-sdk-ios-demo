import DGis
import SwiftUI

class CalcPositionMapObjectsFactory {
	private enum Constants {
		static let redTransparent = Color(argb: 872180589)
		static let redStrong = Color(argb: 4294732653)
		static let blueTransparent = Color(argb: 2131848162)
		static let blueStrong = Color(argb: 4279331810)
	}

	private let imageFactory: IImageFactory
	
	init(imageFactory: IImageFactory) {
		self.imageFactory = imageFactory
	}

	private lazy var markerIcon: DGis.Image = self.imageFactory.make(
		image:(createColoredImage(
			systemName: "plus.circle.fill",
			color: .blue.withAlphaComponent(0.7)
		)?.resized(
			to: CGSize(width: 50.0, height: 50.0))
		)!
	)

	lazy var marker: Marker = createMarker(
		options: MarkerOptions(
			position: .init(latitude: 25.235627, longitude: 55.29713),
			icon: self.markerIcon
		)
	)

	lazy var markers: [Marker] =
	[
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: 25.071997, longitude: 55.140214),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: 25.071997, longitude: 55.143005),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: 25.068618, longitude: 55.143005),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: 25.068618, longitude: 55.140214),
				icon: self.markerIcon
			)
		)
	]

	lazy var markersOn180: [Marker] =
	[
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: 63.744213, longitude: 170.624631),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: 63.744213, longitude: -170.627422),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: 67.740861, longitude: -177.627422),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: 67.740861, longitude: 175.624631),
				icon: self.markerIcon
			)
		)
	]

	lazy var rectMarkersOn180: [Marker] =
	[
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: -53.744213, longitude: 175.624631),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: -53.744213, longitude: -177.627422),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: -57.740861, longitude: -177.627422),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: -57.740861, longitude: 175.624631),
				icon: self.markerIcon
			)
		)
	]

	lazy var rectMarkersOn0: [Marker] =
	[
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: -53.744213, longitude: 25.624631),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: -53.744213, longitude: -27.627422),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: -57.740861, longitude: -27.627422),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: -57.740861, longitude: 25.624631),
				icon: self.markerIcon
			)
		)
	]

	lazy var markersOn0: [Marker] =
	[
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: 63.744213, longitude: 20.624631),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: 63.744213, longitude: -20.627422),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: 67.740861, longitude: -27.627422),
				icon: self.markerIcon
			)
		),
		self.createMarker(
			options: MarkerOptions(
				position: .init(latitude: 67.740861, longitude: 25.624631),
				icon: self.markerIcon
			)
		)
	]

	lazy var circle: DGis.Circle = self.createCircle(
		options: CircleOptions (
			position: GeoPoint(latitude: 25.086884, longitude: 55.164197),
			radius: 1000.0,
			color: Constants.blueTransparent,
			strokeWidth: LogicalPixel(2.0),
			strokeColor: Constants.blueStrong
		)
	)

	lazy var polygon: Polygon = self.createPolygon(
		options: PolygonOptions(
			contours: [[
				GeoPoint(latitude: 25.253017, longitude: 55.141074),
				GeoPoint(latitude: 25.238835, longitude: 55.132338),
				GeoPoint(latitude: 25.229103, longitude: 55.128563),
				GeoPoint(latitude: 25.222866, longitude: 55.126301),
				GeoPoint(latitude: 25.193869, longitude: 55.130075),
				GeoPoint(latitude: 25.18495, longitude: 55.159686),
				GeoPoint(latitude: 25.188401, longitude: 55.173006),
				GeoPoint(latitude: 25.203105, longitude: 55.193172),
				GeoPoint(latitude: 25.215476, longitude: 55.200001),
				GeoPoint(latitude: 25.227086, longitude: 55.204184),
				GeoPoint(latitude: 25.257787, longitude: 55.195266),
				GeoPoint(latitude: 25.263029, longitude: 55.17577),
				GeoPoint(latitude: 25.253017, longitude: 55.141074)
			]],
			color: Constants.redTransparent,
			strokeWidth: LogicalPixel(2.0),
			strokeColor: Constants.redStrong,
			userData: "World Islands"
		)
	)

	private func createMarker(options: MarkerOptions) -> Marker {
		do {
			return try Marker(options: options)
		} catch {
			fatalError("Failed to create marker: \(error.localizedDescription)")
		}
	}

	private func createCircle(options: CircleOptions) -> DGis.Circle {
		do {
			return try Circle(options: options)
		} catch {
			fatalError("Failed to create circle: \(error.localizedDescription)")
		}
	}

	private func createPolygon(options: PolygonOptions) -> Polygon {
		do {
			return try Polygon(options: options)
		} catch {
			fatalError("Failed to create polygon: \(error.localizedDescription)")
		}
	}

	private func createColoredImage(systemName: String, color: UIColor) -> UIImage? {
		let symbolConfiguration = UIImage.SymbolConfiguration(scale: .large)
		let image = UIImage(
			systemName: systemName,
			withConfiguration: symbolConfiguration
		)?.withTintColor(
			color,
			renderingMode: .alwaysOriginal
		)
		return image
	}
}

enum CalcPositionMapObjects: String, CaseIterable {
	case marker
	case markers
	case rectMarkersOn180
	case markersOn180
	case rectMarkersOn0
	case markersOn0
	case polygon
	case circle
	case markersAndCircle

	var displayName: String {
		switch self {
		case .marker: return "Marker"
		case .markers: return "Markers"
		case .rectMarkersOn180: return "Rectangle Markers on 180"
		case .markersOn180: return "Markers on 180"
		case .rectMarkersOn0: return "Rectangle Markers on 0"
		case .markersOn0: return "Markers on 0"
		case .polygon: return "Polygon"
		case .circle: return "Circle"
		case .markersAndCircle: return "Markers and Circle"
		}
	}

	func getObjects(factory: CalcPositionMapObjectsFactory) -> [DGis.SimpleMapObject] {
		switch self {
		case .marker: return [factory.marker]
		case .markers: return factory.markers
		case .markersOn180: return factory.markersOn180
		case .rectMarkersOn180: return factory.rectMarkersOn180
		case .rectMarkersOn0: return factory.rectMarkersOn0
		case .markersOn0: return factory.markersOn0
		case .polygon: return [factory.polygon]
		case .circle: return [factory.circle]
		case .markersAndCircle: return factory.markers + [factory.circle]
		}
	}
}

private extension UIImage {
	func resized(to newSize: CGSize) -> UIImage {
		return UIGraphicsImageRenderer(size: newSize).image { _ in
			self.draw(in: CGRect(origin: .zero, size: newSize))
		}
	}
}

