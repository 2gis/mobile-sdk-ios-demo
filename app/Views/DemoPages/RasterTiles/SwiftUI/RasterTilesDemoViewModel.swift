import Combine
import DGis
import SwiftUI

enum TileSource: String, CaseIterable, Identifiable {
	case dgis = "2GIS"
	case mapBox = "MapBox"
	case nasa = "NASA"
	case openStreetMap = "OpenStreetMap"
	case terrestris = "Terrestris"

	var id: String { self.rawValue }
}

final class RasterTilesDemoViewModel: ObservableObject {
	@Published var selectedSource: TileSource = .terrestris {
		didSet {
			switch self.selectedSource {
			case .dgis:
				self.changeRasterSource(source: self.make2GisSource())
			case .mapBox:
				self.changeRasterSource(source: self.makeMapBoxSource())
			case .nasa:
				self.changeRasterSource(source: self.makeNasaSource())
			case .openStreetMap:
				self.changeRasterSource(source: self.makeOpenStreetMapSource())
			case .terrestris:
				self.changeRasterSource(source: self.makeTerrestrisSource())
			@unknown default:
				assertionFailure("Unknown selectedSource type: \(self)")
			}
			self.rasterTileSource?.setOpacity(opacity: Opacity(value: self.opacity))
		}
	}

	@Published var opacity: Float = 0.3 {
		didSet {
			if oldValue != self.opacity {
				self.rasterTileSource?.setOpacity(opacity: Opacity(value: self.opacity))
			}
		}
	}

	private enum Constants {
		static let dgisApiKey = "6ada8645-d2e6-413e-8d99-ca7d38786023"
		static let dgisUrlTemplate = "https://tile0-sdk.maps.2gis.com/tiles?ts=online_hd&key=\(dgisApiKey)&lang=ru&x={x}&y={y}&z={z}"
		static let mapBoxToken = "pk.eyJ1IjoiZGF5ZW5pbndvcmxkIiwiYSI6ImNrczVyNHV1YzJoZzUycW1zcjAzYnhzbXEifQ.DzQ7SnKQexmnJmw5b5LDyw"
		static let mapBoxUrlTemplate = "https://api.mapbox.com/v4/mapbox.satellite/{z}/{x}/{y}.jpg90?access_token=\(mapBoxToken)"
		static let nasaUrlTemplate = "https://gibs.earthdata.nasa.gov/wmts/epsg3857/best/ASTER_GDEM_Greyscale_Shaded_Relief/default/GoogleMapsCompatible_Level12/{z}/{y}/{x}.jpeg"
		static let openStreetMapUrlTemplate = "https://tile.openstreetmap.org/{z}/{x}/{y}.png"
		static let terrestrisUrlTemplate = "https://ows.terrestris.de/osm/service?SERVICE=WMS&VERSION=1.1.1&REQUEST=GetMap&FORMAT=image/png&TRANSPARENT=true&LAYERS=OSM-Overlay-WMS&HEIGHT=256&WIDTH=256&SRS=EPSG:3857&STYLES=&BBOX="
		static let sublayerName = "testapp_raster_tiles"
	}

	private let map: Map
	private let context: Context
	private var rasterTileSource: RasterTileSource?

	init(
		map: Map,
		context: Context
	) throws {
		self.map = map
		self.context = context
		self.selectedSource = .dgis
		try map.camera.setPosition(
			point: GeoPoint(latitude: 55.740444, longitude: 37.619524),
			zoom: Zoom(9.0)
		)
	}

	private func changeRasterSource(source: RasterTileSource) {
		if let currentSource = self.rasterTileSource {
			self.map.removeSource(source: currentSource)
		}
		self.map.addSource(source: source)
		self.rasterTileSource = source
	}

	private func make2GisSource() -> RasterTileSource {
		RasterTileSource(
			context: self.context,
			sublayerName: Constants.sublayerName,
			sourceTemplate: .defaultSource(.init(urlTemplate: Constants.dgisUrlTemplate))
		)
	}

	private func makeMapBoxSource() -> RasterTileSource {
		RasterTileSource(
			context: self.context,
			sublayerName: Constants.sublayerName,
			sourceTemplate: .defaultSource(.init(urlTemplate: Constants.mapBoxUrlTemplate))
		)
	}

	private func makeNasaSource() -> RasterTileSource {
		RasterTileSource(
			context: self.context,
			sublayerName: Constants.sublayerName,
			sourceTemplate: .defaultSource(.init(urlTemplate: Constants.nasaUrlTemplate))
		)
	}

	private func makeOpenStreetMapSource() -> RasterTileSource {
		RasterTileSource(
			context: self.context,
			sublayerName: Constants.sublayerName,
			sourceTemplate: .defaultSource(.init(urlTemplate: Constants.openStreetMapUrlTemplate))
		)
	}

	private func makeTerrestrisSource() -> RasterTileSource {
		RasterTileSource(
			context: self.context,
			sublayerName: Constants.sublayerName,
			sourceTemplate: .wmsSource(.init(urlTemplate: Constants.terrestrisUrlTemplate))
		)
	}
}
