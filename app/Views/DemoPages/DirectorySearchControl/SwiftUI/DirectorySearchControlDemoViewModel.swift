import Combine
import DGis
import SwiftUI
import UIKit

@MainActor
final class DirectorySearchControlDemoViewModel: ObservableObject, @unchecked Sendable {
	@Published var visibleAreaEdgeInsets = EdgeInsets()
	@Published var objectVisibleAreaEdgeInsets = EdgeInsets()
	@Published var searchExpansionState: DirectorySearchViewExpansionState = .minimum
	@Published private(set) var selectedObject: DirectoryObject?

	let searchManager: SearchManager
	let searchHistory: SearchHistory
	let objectMetricSource: DirectorySearchObjectMetricSource

	private let mapFactory: IMapFactory
	private let myLocationMapObjectSource: MyLocationMapObjectSource
	private let imageFactory: IImageFactory
	private lazy var mapObjectsController: DirectorySearchMapObjectsController = .init(
		map: self.map,
		imageFactory: self.imageFactory,
		logger: self.logger
	)
	private let logger: ILogger
	private let paginationMode: DirectorySearchPaginationMode
	private let categorySource: DirectorySearchResultsDemoCategorySource
	private let categoriesViewProvider: DirectorySearchCategoriesViewProvider?
	private var cameraStateCancellable: DGis.Cancellable?
	private var searchMarkersCancellable: ICancellable?
	private var selectedObjectSearchCancellable: DGis.Cancellable?
	private var searchMarkersGeneration = 0
	private var isMapReady = false
	private var configureMapTask: Task<Void, Never>?

	private var map: Map {
		self.mapFactory.map
	}

#if ROUTING_FEATURE_AVAILABLE
	private let routeMetricProvider: DirectorySearchDrivingTimeMetricProvider
	private let updatesDrivingTimeMetrics: Bool
	private var routeMetricCancellable: AnyCancellable?
#endif

	lazy var configuration: DirectorySearchViewConfiguration = self.makeConfiguration()

#if ROUTING_FEATURE_AVAILABLE
	init(
		mapFactory: IMapFactory,
		searchManager: SearchManager,
		searchHistory: SearchHistory,
		imageFactory: IImageFactory,
		myLocationMapObjectSource: MyLocationMapObjectSource,
		paginationMode: DirectorySearchPaginationMode,
		categorySource: DirectorySearchResultsDemoCategorySource,
		categoriesViewProvider: DirectorySearchCategoriesViewProvider?,
		metricMode: DirectorySearchResultsDemoMetricMode,
		trafficRouter: TrafficRouter,
		locationService: DGis.LocationService,
		logger: ILogger
	) {
		self.mapFactory = mapFactory
		self.searchManager = searchManager
		self.searchHistory = searchHistory
		self.myLocationMapObjectSource = myLocationMapObjectSource
		self.imageFactory = imageFactory
		self.logger = logger
		self.paginationMode = paginationMode
		self.categorySource = categorySource
		self.categoriesViewProvider = categoriesViewProvider
		let routeMetricProvider = DirectorySearchDrivingTimeMetricProvider(
			mapFactory: mapFactory,
			trafficRouter: trafficRouter,
			locationService: locationService
		)
		self.routeMetricProvider = routeMetricProvider
		self.updatesDrivingTimeMetrics = metricMode == .drivingTime
		self.objectMetricSource = switch metricMode {
		case .distance:
			.automatic
		case .drivingTime:
			routeMetricProvider.metricSource
		}
		self.routeMetricCancellable = routeMetricProvider.objectWillChange.sink { [weak self] in
			Task { @MainActor [weak self] in
				self?.objectWillChange.send()
			}
		}
	}
#else
	init(
		mapFactory: IMapFactory,
		searchManager: SearchManager,
		searchHistory: SearchHistory,
		imageFactory: IImageFactory,
		myLocationMapObjectSource: MyLocationMapObjectSource,
		paginationMode: DirectorySearchPaginationMode,
		categorySource: DirectorySearchResultsDemoCategorySource,
		categoriesViewProvider: DirectorySearchCategoriesViewProvider?,
		logger: ILogger
	) {
		self.mapFactory = mapFactory
		self.searchManager = searchManager
		self.searchHistory = searchHistory
		self.myLocationMapObjectSource = myLocationMapObjectSource
		self.imageFactory = imageFactory
		self.logger = logger
		self.paginationMode = paginationMode
		self.categorySource = categorySource
		self.categoriesViewProvider = categoriesViewProvider
		self.objectMetricSource = .automatic
	}
#endif

	func onAppear() {
		self.configureMapTask = Task { @MainActor [weak self] in
			guard let self else { return }
			do {
				let map = try await self.mapFactory.mapAsync
				self.isMapReady = true
				self.addMyLocationSourceIfNeeded(map: map)
				self.subscribeToCameraStateIfNeeded(map: map)
			} catch {
				self.logger.error("Failed to configure directory search demo map: \(error)")
			}
		}
	}

	func onDisappear() {
		self.configureMapTask?.cancel()
		self.configureMapTask = nil
		self.cameraStateCancellable?.cancel()
		self.cameraStateCancellable = nil
		self.selectedObjectSearchCancellable?.cancel()
		self.selectedObjectSearchCancellable = nil
		self.clearSearchMarkers()
	}

	func getMarkerItemInfo(objectInfo: RenderedObjectInfo) {
		self.dismissObjectCard()
		switch objectInfo.item.item {
		case let marker as Marker:
			guard let objectId = marker.userData as? DgisObjectId else { return }
			self.searchById(id: objectId)
		case let mapObject as DgisMapObject:
			self.searchById(id: mapObject.id)
		default:
			return
		}
	}

	func showObjectCard(_ object: DirectoryObject) {
		self.mapObjectsController.moveCamera(to: object)
		self.mapObjectsController.selectObject(object)
		self.selectedObject = object
	}

	func dismissObjectCard() {
		self.mapObjectsController.clearSelection()
		self.selectedObject = nil
	}

	private func makeConfiguration() -> DirectorySearchViewConfiguration {
		DirectorySearchViewConfiguration(
			paginationMode: self.paginationMode,
			pageSize: 10,
			objectMetricSource: self.objectMetricSource,
			searchQueryBuilder: { [weak self] _, builder in
				MainActor.assumeIsolated {
					guard let self, self.isMapReady else { return builder }
					return builder.setAreaOfInterest(rect: self.map.camera.visibleRect)
				}
			},
			suggestQueryBuilder: { [weak self] _, builder in
				MainActor.assumeIsolated {
					guard let self, self.isMapReady else { return builder }
					return builder.setAreaOfInterest(rect: self.map.camera.visibleRect)
				}
			},
			categoryListQueryBuilder: Self.makeCategoryListQueryBuilder(
				categorySource: self.categorySource,
				visibleRectProvider: { [weak self] in
					MainActor.assumeIsolated {
						guard let self, self.isMapReady else { return nil }
						return self.map.camera.visibleRect
					}
				}
			),
			categoryIconProvider: CategoryIconProvider.image(for:),
			categoriesViewProvider: self.categoriesViewProvider,
			onSearchResultCallback: { [weak self] result in
				Task { @MainActor [weak self] in
					self?.updateSearchMarkers(result: result)
				}
			},
			onSearchResultsDismissed: { [weak self] in
				Task { @MainActor [weak self] in
					self?.clearSearchMarkers()
				}
			},
			onSearchObjectsChanged: self.searchObjectsChangedCallback
		)
	}

	private var searchObjectsChangedCallback: DirectorySearchObjectsCallback? {
#if ROUTING_FEATURE_AVAILABLE
		guard self.updatesDrivingTimeMetrics else { return nil }
		return { [weak self] objects in
			Task { @MainActor [weak self] in
				self?.routeMetricProvider.updateObjects(objects)
			}
		}
#else
		nil
#endif
	}

	private func updateSearchMarkers(result: SearchResult) {
		self.clearSearchMarkers()
		let generation = self.searchMarkersGeneration
		self.searchMarkersCancellable = result.itemMarkerInfos.sinkOnMainThread(
			receiveValue: { [weak self] markerInfos in
				Task { @MainActor [weak self] in
					guard let self,
					      self.searchMarkersGeneration == generation
					else { return }
					self.mapObjectsController.replaceMarkers(markerInfos ?? [])
				}
			},
			failure: { [weak self] error in
				Task { @MainActor [weak self] in
					guard let self,
					      self.searchMarkersGeneration == generation
					else { return }
					self.logger.error("Failed to get search markers: \(error)")
				}
			}
		)
	}

	private func clearSearchMarkers() {
		self.searchMarkersGeneration += 1
		self.searchMarkersCancellable?.cancel()
		self.searchMarkersCancellable = nil
		self.mapObjectsController.clearMarkers()
	}

	private func searchById(id: DgisObjectId) {
		self.selectedObjectSearchCancellable?.cancel()
		self.selectedObjectSearchCancellable = self.searchManager
			.searchByDirectoryObjectIds(objectIds: [id])
			.sinkOnMainThread(
				receiveValue: { [weak self] objects in
					Task { @MainActor [weak self] in
						guard let self, let object = objects.first else { return }
						if let branch = object.group.first(where: { $0.type == .branch }) {
							self.searchById(id: branch.id)
							return
						}
						self.showObjectCard(object)
					}
				},
				failure: { [weak self] error in
					Task { @MainActor [weak self] in
						self?.logger.error("Failed to get object data: \(error)")
					}
				}
			)
	}

	private func addMyLocationSourceIfNeeded(map: Map) {
		guard !map.sources.contains(self.myLocationMapObjectSource) else { return }
		map.addSource(source: self.myLocationMapObjectSource)
	}

	private func subscribeToCameraStateIfNeeded(map: Map) {
		guard self.cameraStateCancellable == nil else { return }
		self.cameraStateCancellable = map.camera.sinkOnStatefulChangesOnMainThread(reason: .state) {
			[weak self] (state: CameraState) in
			Task { @MainActor [weak self] in
				guard let self,
				      state == .busy,
				      self.selectedObject == nil,
				      self.searchExpansionState != .minimum
				else { return }
				self.searchExpansionState = .minimum
			}
		}
	}

	private static func makeCategoryListQueryBuilder(
		categorySource: DirectorySearchResultsDemoCategorySource,
		visibleRectProvider: @escaping () -> GeoRect?
	) -> DirectoryCategoryListQueryBuilder? {
		switch categorySource {
		case .currentPosition:
			nil
		case .visibleRect:
			{ builder in
				guard let visibleRect = visibleRectProvider() else { return builder }
				return builder.setGeoContext(geoContext: .geoRect(visibleRect))
			}
		}
	}
}

private final class DirectorySearchMapObjectsController: @unchecked Sendable {
	private enum Constants {
		nonisolated static let defaultMarkerIconWidth: LogicalPixel = 27.0
		nonisolated static let selectedMarkerIconWidth: LogicalPixel = 34.0
		nonisolated static let markerTextFontSize: LogicalPixel = 12.0
	}

	private struct MarkerBuildResult {
		let markers: [DgisObjectId: Marker]
		let markerList: [Marker]
		let failedMarkersCount: Int
	}

	private let map: Map
	private let mapObjectManager: MapObjectManager
	private let markerIcon: DGis.Image?
	private let selectedMarkerIcon: DGis.Image?
	private let logger: ILogger
	private var markers: [DgisObjectId: Marker] = [:]
	private var selectedObjectId: DgisObjectId?
	private var selectedObjectMarker: Marker?
	private var markerBuildTask: Task<Void, Never>?
	private var markerBuildGeneration = 0

	init(map: Map, imageFactory: IImageFactory, logger: ILogger) {
		self.map = map
		self.mapObjectManager = MapObjectManager.withGeneralization(
			map: map,
			logicalPixel: 80.0,
			maxZoom: map.camera.zoomRestrictions.maxZoom
		)
		self.markerIcon = Self.makeMarkerIcon(imageFactory: imageFactory, color: .systemBlue)
		self.selectedMarkerIcon = Self.makeMarkerIcon(imageFactory: imageFactory, color: .systemRed)
		self.logger = logger
	}

	func replaceMarkers(_ markerInfos: [ItemMarkerInfo]) {
		self.markerBuildGeneration += 1
		let generation = self.markerBuildGeneration
		let selectedObjectId = self.selectedObjectId
		let markerIcon = self.markerIcon
		let selectedMarkerIcon = self.selectedMarkerIcon
		self.markerBuildTask?.cancel()
		self.markerBuildTask = Task.detached(priority: .utility) { [weak self] in
			guard let result = Self.makeMarkers(
				markerInfos: markerInfos,
				selectedObjectId: selectedObjectId,
				markerIcon: markerIcon,
				selectedMarkerIcon: selectedMarkerIcon
			) else { return }
			await self?.applyMarkerBuildResult(result, generation: generation)
		}
	}

	func clearMarkers() {
		self.markerBuildGeneration += 1
		self.markerBuildTask?.cancel()
		self.markerBuildTask = nil
		let removedMarkers = self.markers
		self.markers = [:]
		self.selectedObjectId = nil
		self.selectedObjectMarker = nil
		self.mapObjectManager.removeAll()
		Task.detached(priority: .utility) {
			_ = removedMarkers
		}
	}

	func selectObject(_ object: DirectoryObject) {
		self.clearSelection()
		self.selectedObjectId = object.id
		if let objectId = object.id,
		   let marker = self.markers[objectId]
		{
			self.setSelectedStyle(marker)
			return
		}

		do {
			guard let marker = try self.makeSelectedMarker(object: object) else { return }
			self.selectedObjectMarker = marker
			self.mapObjectManager.addObject(item: marker)
		} catch {
			self.logger.error("Failed to create selected object marker: \(error)")
		}
	}

	func clearSelection() {
		if let selectedObjectId,
		   let marker = self.markers[selectedObjectId]
		{
			self.setDefaultStyle(marker)
		}
		if let selectedObjectMarker {
			self.mapObjectManager.removeObject(item: selectedObjectMarker)
			self.selectedObjectMarker = nil
		}
		self.selectedObjectId = nil
	}

	func moveCamera(to object: DirectoryObject) {
		guard let point = object.markerPosition?.point else { return }
		_ = self.map.camera.move(
			point: point,
			zoom: self.map.camera.position.zoom,
			tilt: self.map.camera.position.tilt,
			bearing: self.map.camera.position.bearing
		)
	}

	private func applyMarkerBuildResult(_ result: MarkerBuildResult, generation: Int) {
		guard self.markerBuildGeneration == generation else { return }
		let oldMarkers = self.markers
		self.mapObjectManager.removeAll()
		self.markers = result.markers
		var markersToAdd = result.markerList
		if let selectedObjectId,
		   let marker = result.markers[selectedObjectId]
		{
			self.setSelectedStyle(marker)
			self.selectedObjectMarker = nil
		} else if let selectedObjectMarker {
			markersToAdd.append(selectedObjectMarker)
		}
		self.mapObjectManager.addObjects(objects: markersToAdd)
		if result.failedMarkersCount > 0 {
			self.logger.error("Failed to create \(result.failedMarkersCount) search markers")
		}

		Task.detached(priority: .utility) {
			_ = oldMarkers
		}
	}

	private func setDefaultStyle(_ marker: Marker) {
		marker.icon = self.markerIcon
		marker.iconWidth = Constants.defaultMarkerIconWidth
	}

	private func setSelectedStyle(_ marker: Marker) {
		marker.icon = self.selectedMarkerIcon
		marker.iconWidth = Constants.selectedMarkerIconWidth
	}

	private func makeSelectedMarker(object: DirectoryObject) throws -> Marker? {
		guard let position = object.markerPosition else { return nil }
		let userData: Any = object.id.map { $0 as Any } ?? ()
		return try Marker(options: MarkerOptions(
			position: position,
			icon: self.selectedMarkerIcon,
			text: object.title,
			textStyle: TextStyle(
				fontSize: Constants.markerTextFontSize,
				color: DGis.Color(.label)!,
				strokeWidth: 2.0,
				strokeColor: DGis.Color(.systemBackground)!,
				textPlacement: .rightCenter,
				textOffset: 0.0
			),
			iconWidth: Constants.selectedMarkerIconWidth,
			userData: userData
		))
	}

	private nonisolated static func makeMarkers(
		markerInfos: [ItemMarkerInfo],
		selectedObjectId: DgisObjectId?,
		markerIcon: DGis.Image?,
		selectedMarkerIcon: DGis.Image?
	) -> MarkerBuildResult? {
		var markers: [DgisObjectId: Marker] = [:]
		var markerList: [Marker] = []
		markerList.reserveCapacity(markerInfos.count)
		var failedMarkersCount = 0
		for markerInfo in markerInfos {
			guard !Task.isCancelled else { return nil }
			guard let objectId = markerInfo.objectId else { continue }
			let isSelected = objectId == selectedObjectId
			do {
				let marker = try Marker(options: MarkerOptions(
					position: markerInfo.geoPoint,
					icon: isSelected ? selectedMarkerIcon : markerIcon,
					text: markerInfo.title,
					textStyle: TextStyle(
						fontSize: Constants.markerTextFontSize,
						color: DGis.Color(.label)!,
						strokeWidth: 2.0,
						strokeColor: DGis.Color(.systemBackground)!,
						textPlacement: .rightCenter,
						textOffset: 0.0
					),
					iconWidth: isSelected
						? Constants.selectedMarkerIconWidth
						: Constants.defaultMarkerIconWidth,
					userData: objectId
				))
				markers[objectId] = marker
				markerList.append(marker)
			} catch {
				failedMarkersCount += 1
			}
		}
		return MarkerBuildResult(
			markers: markers,
			markerList: markerList,
			failedMarkersCount: failedMarkersCount
		)
	}

	private static func makeMarkerIcon(imageFactory: IImageFactory, color: UIColor) -> DGis.Image? {
		guard let image = UIImage(systemName: "circle.circle.fill")?
			.withTintColor(color, renderingMode: .alwaysOriginal)
		else { return nil }
		return imageFactory.make(image: image)
	}
}

#if ROUTING_FEATURE_AVAILABLE
private final class DirectorySearchDrivingTimeMetricProvider: ObservableObject {
	@Published private(set) var revision = 0

	private let mapFactory: IMapFactory
	private let trafficRouter: TrafficRouter
	private let locationService: DGis.LocationService
	private var briefInfoCancellable: ICancellable = NoopCancellable()
	private var pendingObjects: [DirectoryObject] = []
	private var metricByObjectKey: [String: String] = [:]
	private var resolvedObjectKeys: Set<String> = []
	private var currentObjectKey: String?
	private var currentStartPoint: GeoPoint?
	private var requestGeneration = 0

	var metricSource: DirectorySearchObjectMetricSource {
		.provider { [weak self] object in
			self?.metric(for: object)
		}
	}

	init(
		mapFactory: IMapFactory,
		trafficRouter: TrafficRouter,
		locationService: DGis.LocationService
	) {
		self.mapFactory = mapFactory
		self.trafficRouter = trafficRouter
		self.locationService = locationService
	}

	func updateObjects(_ objects: [DirectoryObject]) {
		let startPoint = self.startPoint
		if self.currentStartPoint != startPoint {
			self.currentStartPoint = startPoint
			self.metricByObjectKey = [:]
			self.resolvedObjectKeys = []
			self.currentObjectKey = nil
			self.briefInfoCancellable.cancel()
			self.requestGeneration += 1
		}

		let newObjects = objects.filter { object in
			let key = self.key(for: object)
			return !self.resolvedObjectKeys.contains(key)
		}
		self.pendingObjects = newObjects
		self.processNextObjectIfNeeded()
	}

	private func metric(for object: DirectoryObject) -> String? {
		self.metricByObjectKey[self.key(for: object)]
	}

	private func processNextObjectIfNeeded() {
		guard self.currentObjectKey == nil else { return }
		guard let startPoint = self.startPoint else { return }

		while !self.pendingObjects.isEmpty {
			let object = self.pendingObjects.removeFirst()
			let key = self.key(for: object)
			guard !self.resolvedObjectKeys.contains(key),
			      let finishPoint = object.markerPosition?.point
			else {
				continue
			}

			let searchPoints = BriefRouteInfoSearchPoints(
				startPoint: RouteSearchPoint(coordinates: startPoint),
				finishPoint: RouteSearchPoint(coordinates: finishPoint)
			)
			let future = self.trafficRouter.findBriefRouteInfos(
				searchPoints: [searchPoints],
				routeSearchOptions: .car(.init())
			)
			self.currentObjectKey = key
			self.requestGeneration += 1
			let requestGeneration = self.requestGeneration
			self.briefInfoCancellable = future.sinkOnMainThread(
				receiveValue: { [weak self] briefInfos in
					Task { @MainActor [weak self] in
						self?.handle(briefInfos, requestGeneration: requestGeneration)
					}
				},
				failure: { [weak self] _ in
					Task { @MainActor [weak self] in
						self?.completeCurrentRequest(requestGeneration: requestGeneration)
					}
				}
			)
			return
		}
	}

	private func handle(_ briefInfos: [BriefRouteInfo?], requestGeneration: Int) {
		guard self.requestGeneration == requestGeneration,
		      let currentObjectKey
		else { return }

		self.resolvedObjectKeys.insert(currentObjectKey)
		if let duration = briefInfos.first??.duration {
			self.metricByObjectKey[currentObjectKey] = self.formatDuration(seconds: Double(duration))
		}
		self.completeCurrentRequest(requestGeneration: requestGeneration)
	}

	private func completeCurrentRequest(requestGeneration: Int) {
		guard self.requestGeneration == requestGeneration else { return }
		self.currentObjectKey = nil
		self.revision += 1
		self.processNextObjectIfNeeded()
	}

	private var startPoint: GeoPoint? {
		self.locationService.lastLocation?.coordinates.value ?? self.mapFactory.map.camera.position.point
	}

	private func key(for object: DirectoryObject) -> String {
		if let objectId = object.id {
			return String(describing: objectId)
		}
		if let point = object.markerPosition?.point {
			return "\(object.title)-\(point.latitude.value)-\(point.longitude.value)"
		}
		return object.title
	}

	private func formatDuration(seconds: Double) -> String {
		let minutes = max(1, Int((seconds / 60).rounded(.up)))
		guard minutes >= 60 else {
			return "\(minutes) min"
		}

		let hours = minutes / 60
		let remainingMinutes = minutes % 60
		guard remainingMinutes > 0 else {
			return "\(hours) h"
		}
		return "\(hours) h \(remainingMinutes) min"
	}
}
#endif
