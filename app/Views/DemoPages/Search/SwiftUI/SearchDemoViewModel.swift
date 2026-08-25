import Combine
import DGis
import SwiftUI

@MainActor
final class SearchDemoViewModel: ObservableObject, @unchecked Sendable {
	private enum Constants {
		static let directoryStateKey = "Global/DirectoryState"
		static let moscowPosition = GeoPoint(latitude: 55.7522200, longitude: 37.6155600)
		static let defaultZoom = Zoom(value: 10.0)
	}

	struct SearchItemInfo {
		var id: String
		var coordinate: String
		var title: String
		var subTitle: String
		var address: String
	}

	@Published var showCloseMenu: Bool = false
	@Published var showInfo: Bool = false
	@Published var searchItemInfo = SearchItemInfo(
		id: "",
		coordinate: "",
		title: "",
		subTitle: "",
		address: ""
	)

	let searchStore: SearchStore
	let logger: ILogger

	private let searchManager: SearchManager
	private let searchHistory: SearchHistory
	private let map: Map
	private let imageFactory: IImageFactory
	private let locationService: DGis.LocationService
	private let service: SearchService
	private let history: SearchHistoryService
	private lazy var storage: IKeyValueStorage = UserDefaults.standard
	private var objectInfoCancellable: DGis.Cancellable?
	private var searchResultCancellable: DGis.Cancellable?

	init(
		searchManager: SearchManager,
		map: Map,
		imageFactory: IImageFactory,
		mapSourceFactory: IMapSourceFactory,
		locationService: DGis.LocationService,
		logger: ILogger,
		searchHistory: SearchHistory
	) throws {
		self.searchManager = searchManager
		self.searchHistory = searchHistory
		self.map = map
		self.imageFactory = imageFactory
		self.locationService = locationService
		self.logger = logger
		self.history = SearchHistoryService(searchHistory: self.searchHistory)
		self.service = SearchService(
			searchManager: self.searchManager,
			searchHistory: self.history,
			map: self.map,
			imageFactory: self.imageFactory,
			logger: self.logger,
			locationService: self.locationService
		)
		let reducer = SearchReducer(service: self.service, history: self.history)
		self.searchStore = SearchStore(initialState: .init(), reducer: reducer)
		try self.map.camera.setPosition(
			point: Constants.moscowPosition,
			zoom: Constants.defaultZoom
		)
		let locationSource = mapSourceFactory.makeMyLocationMapObjectSource(bearingSource: .magnetic)
		self.map.addSource(source: locationSource)
	}

	func saveState() {
		if let lastSearchQuery = self.service.lastSearchQuery {
			let directoryState = PackedSearchQuery.fromSearchQuery(searchQuery: lastSearchQuery)
			self.storage.set(
				directoryState.toBytes().base64EncodedString(),
				forKey: Constants.directoryStateKey
			)
		}
	}

	func restoreState() {
		let camera = self.map.camera
		guard
			let rawValue: String = self.storage.value(forKey: Constants.directoryStateKey),
			let storedDirectoryState = Data(base64Encoded: rawValue),
			let directoryState = try? PackedSearchQuery.fromBytes(data: storedDirectoryState)
		else {
			do {
				try camera.setPosition(point: Constants.moscowPosition, zoom: Constants.defaultZoom)
			} catch let error as SimpleError {
				self.logger.error("Failed to set default camera state: \(error.description)")
			} catch {
				self.logger.error("Failed to set default camera state: \(error)")
			}
			return
		}

		if let areaOfInterest = directoryState.areaOfInterest {
			let geometry = self.geoRectToPolygonGeometry(geoRect: areaOfInterest)
			let cameraPosition = calcPosition(
				camera: camera,
				geometry: geometry
			)
			do {
				try camera.setPosition(position: cameraPosition)
			} catch let error as SimpleError {
				self.logger.error("Failed to restore state: \(error.description)")
			} catch {
				self.logger.error("Failed to restore state: \(error)")
			}
		}
		self.searchStore.state.queryText = directoryState.queryText
		self.service.search(query: directoryState.toSearchQuery(), title: "", subtitle: "", addToHistory: false).callAsFunction { [weak self] action in
			Task { @MainActor [weak self] in
				if case let .setSearchResult(result) = action {
					self?.searchStore.state.result = result
				}
			}
		}
	}

	func getMarkerItemInfo(objectInfo: RenderedObjectInfo) {
		switch objectInfo.item.item {
		case let marker as Marker:
			self.searchById(id: marker.userData as! DgisObjectId)
			return
		default:
			return
		}
	}

	private func searchById(id: DgisObjectId) {
		self.searchResultCancellable = self.searchManager.searchByDirectoryObjectId(
			objectId: id
		).sinkOnMainThread { [weak self] result in
			Task { @MainActor [weak self] in
				guard let self,
				      let object = result,
				      let id = object.id,
				      let point = object.markerPosition?.point
				else { return }
				self.searchItemInfo = .init(
					id: "\(id.objectId)",
					coordinate: "Latitude: \(point.latitude.value), Longitude: \(point.longitude.value)",
					title: object.title,
					subTitle: object.subtitle,
					address: object.formattedAddress(type: .short)?.streetAddress ?? "(no address)"
				)
				self.showInfo = true
				_ = self.map.camera.move(
					position: .init(
						point: point,
						zoom: self.map.camera.position.zoom,
						tilt: self.map.camera.position.tilt,
						bearing: self.map.camera.position.bearing
					),
					time: 0.3,
					animationType: .linear
				)
			}
		} failure: { error in
			Task { @MainActor [weak self] in
				self?.logger.error("Failed to get object data: \(error)")
			}
		}
	}

	private func geoRectToPolygonGeometry(geoRect: GeoRect) -> PolygonGeometry {
		let points = [
			geoRect.southWestPoint,
			GeoPoint(
				latitude: geoRect.southWestPoint.latitude,
				longitude: geoRect.northEastPoint.longitude
			),
			geoRect.northEastPoint,
			GeoPoint(
				latitude: geoRect.northEastPoint.latitude,
				longitude: geoRect.southWestPoint.longitude
			),
		]
		return PolygonGeometry(contours: [points])
	}
}
