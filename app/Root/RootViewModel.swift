import SwiftUI
import PlatformSDK

final class RootViewModel: ObservableObject {

	private enum Constants {
		static let tapRadius = ScreenDistance(value: 1)
		static let initialRectExpansionRatio = 1.5
	}

	enum VisibleAreaState {
		case inside
		case outside
	}

	let searchStore: SearchStore

	@Published var showMarkers: Bool = false
	@Published var showRoutes: Bool = false
	@Published var selectedObjectCardViewModel: MapObjectCardViewModel?
	@Published var visibleAreaIndicatorState: VisibleAreaState?

	private let searchManagerFactory: () -> SearchManager
	private let sourceFactory: () -> ISourceFactory
	private let imageFactory: () -> IImageFactory
	private let locationManagerFactory: () -> LocationService?
	private let map: Map
	private let toMap: CGAffineTransform
	private var locationService: LocationService?
	private var initialRect: GeoRect?
	private var initialRectCancellable: Cancellable?

	private var moveCameraCancellable: Cancellable?
	private var getRenderedObjectsCancellable: Cancellable?
	private var getDirectoryObjectCancellable: Cancellable?
	private var selectedMarker: Marker?
	private lazy var mapObjectManager: MapObjectManager = createMapObjectManager(map: self.map)
	private lazy var selectedMarkerIcon: PlatformSDK.Image = {
		let factory = self.imageFactory()
		let icon = UIImage(systemName: "mappin.and.ellipse")!
			.withTintColor(#colorLiteral(red: 0.2470588235, green: 0.6, blue: 0.1607843137, alpha: 1))
			.withConfiguration(UIImage.SymbolConfiguration(scale: .large))
		return factory.make(image: icon)
	}()

	private let testPoints: [(position: CameraPosition, time: TimeInterval, type: CameraAnimationType)] = {
		return [
			(.init(
				point: .init(latitude: .init(value: 55.759909), longitude: .init(value: 37.618806)),
				zoom: .init(value: 15),
				tilt: .init(value: 15),
				bearing: .init(value: 115)
			), 4, .linear),
			(.init(
				point: .init(latitude: .init(value: 55.759909), longitude: .init(value: 37.618806)),
				zoom: .init(value: 16),
				tilt: .init(value: 15),
				bearing: .init(value: 0)
			), 4, .default),
			(.init(
				point: .init(latitude: .init(value: 55.746962), longitude: .init(value: 37.643073)),
				zoom: .init(value: 16),
				tilt: .init(value: 55),
				bearing: .init(value: 0)
			), 9, .showBothPositions),
			(.init(
				point: .init(latitude: .init(value: 55.746962), longitude: .init(value: 37.643073)),
				zoom: .init(value: 16.5),
				tilt: .init(value: 45),
				bearing: .init(value: 40)
			), 4, .linear),
			(.init(
				point: .init(latitude: .init(value: 55.752425), longitude: .init(value: 37.613983)),
				zoom: .init(value: 16),
				tilt: .init(value: 25),
				bearing: .init(value: 85)
			), 4, .default)
		]
	}()

	init(
		searchManagerFactory: @escaping () -> SearchManager,
		sourceFactory: @escaping () -> ISourceFactory,
		imageFactory: @escaping () -> IImageFactory,
		locationManagerFactory: @escaping () -> LocationService?,
		map: Map
	) {
		self.searchManagerFactory = searchManagerFactory
		self.sourceFactory = sourceFactory
		self.imageFactory = imageFactory
		self.locationManagerFactory = locationManagerFactory
		self.map = map

		let scale = UIScreen.main.nativeScale
		self.toMap = CGAffineTransform(scaleX: scale, y: scale)

		let service = SearchService(
			searchManagerFactory: self.searchManagerFactory,
			scheduler: DispatchQueue.main
		)
		let reducer = SearchReducer(service: service)
		self.searchStore = SearchStore(initialState: .init(), reducer: reducer)
	}

	func makeSearchViewModel() -> SearchViewModel {
		let service = SearchService(
			searchManagerFactory: self.searchManagerFactory,
			scheduler: DispatchQueue.main
		)
		let viewModel = SearchViewModel(
			searchStore: self.searchStore,
			searchService: service
		)
		return viewModel
	}

	func testCamera() {
		self.move(at: 0)
	}

	func showCurrentPosition() {
		if self.locationService == nil {
			self.locationService = self.locationManagerFactory()
		}
		self.locationService?.getCurrentPosition { (coordinates) in
			DispatchQueue.main.async {
				self.moveCameraCancellable?.cancel()
				self.moveCameraCancellable = self.map
					.camera
					.move(
						position: CameraPosition(
							point: GeoPoint(latitude: .init(value: coordinates.latitude), longitude: .init(value: coordinates.longitude)),
							zoom: .init(value: 14),
							tilt: .init(value: 15),
							bearing: .init(value: 0)
						),
						time: 1.0,
						animationType: .linear
					).sink { _ in
						print("Move to current location")
					} failure: { error in
						print("Something went wrong: \(error.localizedDescription)")
					}
			}
		}
	}

	func tap(_ location: CGPoint) {
		let mapLocation = location.applying(self.toMap)
		let tapPoint = ScreenPoint(x: Float(mapLocation.x), y: Float(mapLocation.y))
		self.tap(point: tapPoint, tapRadius: Constants.tapRadius)
	}

	/// - Parameter point: A tap point in *pixel* (native scale) cooordinates.
	/// - Parameter tapRadius: Radius around tap point in which objects will
	///   be detected.
	private func tap(point: ScreenPoint, tapRadius: ScreenDistance) {
		self.hideSelectedMarker()
		self.getRenderedObjectsCancellable?.cancel()

		let cancel = self.map.getRenderedObjects(centerPoint: point, radius: tapRadius).sink(
			receiveValue: {
				infos in
				// The first object is the closest one to the tapped point.
				guard let info = infos.first else { return }
				DispatchQueue.main.async {
					[weak self] in
					self?.handle(selectedObject: info)
				}
			},
			failure: { error in
				print("Failed to fetch objects: \(error)")
			}
		)
		self.getRenderedObjectsCancellable = cancel
	}

	
	func detectExtendedVisibleRectChange() {
		let visibleRectChannel = self.map.camera.visibleRect
		self.formInitialVisibleRect(from: visibleRectChannel.value)
		self.initialRectCancellable = visibleRectChannel.sinkOnMainThread{ [weak self] rect in
			self?.updateVisibleRect(rect)
		}
	}
	
	private func move(at index: Int) {

		guard index < self.testPoints.count else { return }
		let tuple = self.testPoints[index]
		DispatchQueue.main.async {
			self.moveCameraCancellable?.cancel()
			self.moveCameraCancellable = self.map
				.camera
				.move(
					position: tuple.position,
					time: tuple.time,
					animationType: tuple.type
				).sink { [weak self] _ in
					self?.move(at: index + 1)
				} failure: { error in
					print("Something went wrong: \(error.localizedDescription)")
				}
		}
	}

	private func hideSelectedMarker() {
		if let marker = self.selectedMarker {
			marker.remove()
		}
		self.selectedObjectCardViewModel = nil
	}

	private func handle(selectedObject: RenderedObjectInfo) {
		let mapPoint = selectedObject.closestMapPoint
		let markerPoint = GeoPointWithElevation(
			latitude: mapPoint.latitude,
			longitude: mapPoint.longitude
		)
		let markerOptions = MarkerOptions(
			position: markerPoint,
			icon: self.selectedMarkerIcon
		)
		self.selectedMarker = self.mapObjectManager.addMarker(options: markerOptions)
		self.selectedObjectCardViewModel = MapObjectCardViewModel(
			objectInfo: selectedObject,
            searchManagerFactory: searchManagerFactory,
			onClose: {
				[weak self] in
				self?.hideSelectedMarker()
			}
		)
	}

	private func formInitialVisibleRect(from rect: GeoRect) {
		self.initialRect = rect.expanded(by: Constants.initialRectExpansionRatio)
	}

	private func updateVisibleRect(_ rect: GeoRect) {
		if let initialRect = self.initialRect,
			initialRect.contains(rect) {
			// Current visible rect is within the initial expanded rect.
			self.visibleAreaIndicatorState = .inside
		} else {
			// Current visible rect is outside the initial expanded rect.
			self.visibleAreaIndicatorState = .outside
		}
	}
}
