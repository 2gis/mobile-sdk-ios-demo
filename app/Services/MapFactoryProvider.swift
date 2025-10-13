import DGis
import UIKit

protocol IMapProvider: AnyObject {
	@MainActor
	var map: DGis.Map { get }
}

protocol IMapSnapshotterProvider: AnyObject {
	@MainActor
	var snapshotter: IMapSnapshotter { get }
}

enum MapGesturesType: CaseIterable, Equatable {
	enum ScalingCenter {
		case camera, event
	}

	case `default`(ScalingCenter), custom

	static let allCases: [MapGesturesType] = [.default(.camera), .default(.event), custom]

	static func == (lhs: MapGesturesType, rhs: MapGesturesType) -> Bool {
		switch (lhs, rhs) {
		case (.custom, .custom):
			true
		case let (.default(lhs), .default(rhs)):
			lhs == rhs
		default:
			false
		}
	}
}

protocol IMapFactoryProvider: AnyObject {
	var mapFactory: DGis.IMapFactory { get }

	@MainActor
	func makeGestureView(mapGesturesType: MapGesturesType) -> (UIView & IMapGestureUIView)?
}

class MapFactoryProvider: @preconcurrency IMapFactoryProvider {
	@MainActor
	private(set) lazy var mapFactory: DGis.IMapFactory = self.makeMapFactory()

	private let sdkContainer: DGis.Container
	private let mapGesturesType: MapGesturesType

	init(container: DGis.Container, mapGesturesType: MapGesturesType) {
		self.sdkContainer = container
		self.mapGesturesType = mapGesturesType
	}

	func makeGestureView(mapGesturesType: MapGesturesType) -> (UIView & IMapGestureUIView)? {
		let factory: IMapGestureUIViewFactory? = self.makeGestureViewFactory(mapGesturesType: mapGesturesType)
		return factory?.makeGestureUIView(
			map: self.mapFactory.map,
			eventProcessor: self.mapFactory.mapEventProcessor,
			coordinateSpace: self.mapFactory.mapCoordinateSpace
		)
	}

	@MainActor
	func resetMapFactory() {
		self.mapFactory = self.makeMapFactory()
	}

	@MainActor
	private func makeMapFactory() -> IMapFactory {
		var options = MapOptions.default
		options.gestureUIViewFactory = self.makeGestureViewFactory(mapGesturesType: self.mapGesturesType)
		do {
			return try self.sdkContainer.makeMapFactory(options: options)
		} catch {
			fatalError("IMapFactory initialization error: \(error)")
		}
	}

	private func makeGestureViewFactory(mapGesturesType: MapGesturesType) -> IMapGestureUIViewFactory {
		switch mapGesturesType {
		case let .default(scalingCenter):
			let center: MapGestureViewOptions.ScalingCenter = switch scalingCenter {
			case .camera:
				.cameraPosition
			case .event:
				.eventCenter
			}
			return MapGestureUIViewFactory(
				options: MapGestureViewOptions(
					doubleTapScalingCenter: center,
					twoFingerTapScalingCenter: center,
					pinchScalingCenter: center
				)
			)
		case .custom:
			return CustomGestureViewFactory()
		}
	}
}

extension MapFactoryProvider: IMapProvider {
	var map: Map {
		self.mapFactory.map
	}
}

extension MapFactoryProvider: IMapSnapshotterProvider {
	var snapshotter: IMapSnapshotter {
		self.mapFactory.snapshotter
	}
}
