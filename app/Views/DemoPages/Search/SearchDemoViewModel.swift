import SwiftUI
import Combine
import DGis

final class SearchDemoViewModel: ObservableObject {
	private enum Constants {
		static let directoryStateKey = "Global/DirectoryState"
	}

	@Published var showCloseMenu: Bool = false

	let searchStore: SearchStore

	private let searchManager: SearchManager
	private let map: Map
	private let locationService: DGis.ILocationService
	private let service: SearchService
	private lazy var storage: IKeyValueStorage = UserDefaults.standard

	init(
		searchManager: SearchManager,
		map: Map,
		locationService: DGis.ILocationService
	) throws {
		self.searchManager = searchManager
		self.map = map
		self.locationService = locationService
		self.service = SearchService(
			searchManager: self.searchManager,
			map: self.map,
			locationService: self.locationService,
			scheduler: DispatchQueue.main
		)
		let reducer = SearchReducer(service: self.service)
		self.searchStore = SearchStore(initialState: .init(), reducer: reducer)
	}

	func makeSearchViewModel() -> SearchViewModel {
		let service = SearchService(
			searchManager: self.searchManager,
			map: self.map,
			locationService: self.locationService,
			scheduler: DispatchQueue.main
		)
		let viewModel = SearchViewModel(
			searchStore: self.searchStore,
			searchService: service
		)
		return viewModel
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
				print("Failed to restore state: \(error.description)")
			} catch {
				print("Failed to restore state: \(error)")
			}
		}
		self.searchStore.state.queryText = directoryState.queryText
		self.service.search(query: directoryState.toSearchQuery()).callAsFunction { [weak self] action in
			if case let .setSearchResult(result) = action {
				self?.searchStore.state.result = result
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
			)
		]
		return PolygonGeometry(contours: [points])
	}
}
