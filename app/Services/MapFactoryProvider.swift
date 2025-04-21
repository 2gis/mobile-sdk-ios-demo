import UIKit
import DGis

protocol IMapProvider: AnyObject {
	var map: DGis.Map { get }
}

protocol IMapSnapshotterProvider: AnyObject {
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
				return true
			case (.default(let lhs), .default(let rhs)):
				return lhs == rhs
			default:
				return false
		}
	}
}

protocol IMapFactoryProvider: AnyObject {
	var mapFactory: DGis.IMapFactory { get }

	func makeGestureView(mapGesturesType: MapGesturesType) -> (UIView & IMapGestureView)?
}

class MapFactoryProvider: IMapFactoryProvider {
	private(set) lazy var mapFactory: DGis.IMapFactory = self.makeMapFactory()

	private let sdkContainer: DGis.Container
	private let mapGesturesType: MapGesturesType

	init(container: DGis.Container, mapGesturesType: MapGesturesType) {
		self.sdkContainer = container
		self.mapGesturesType = mapGesturesType
	}

	func makeGestureView(mapGesturesType: MapGesturesType) -> (UIView & IMapGestureView)? {
		let factory: IMapGestureViewFactory? = self.makeGestureViewFactory(mapGesturesType: mapGesturesType)
		return factory?.makeGestureView(
			map: self.mapFactory.map,
			eventProcessor: self.mapFactory.mapEventProcessor,
			coordinateSpace: self.mapFactory.mapCoordinateSpace
		)
	}

	func resetMapFactory() {
		self.mapFactory = self.makeMapFactory()
	}

	private func makeMapFactory() -> IMapFactory {
		var options = MapOptions.default
		options.gestureViewFactory = self.makeGestureViewFactory(mapGesturesType: self.mapGesturesType)
		do {
			return try self.sdkContainer.makeMapFactory(options: options)
		} catch {
			fatalError("IMapFactory initialization error: \(error)")
		}
	}

	private func makeGestureViewFactory(mapGesturesType: MapGesturesType) -> IMapGestureViewFactory {
		switch mapGesturesType {
			case .default(let scalingCenter):
				let center: MapGestureViewOptions.ScalingCenter
				switch scalingCenter {
					case .camera:
						center = .cameraPosition
					case .event:
						center = .eventCenter
				}
				return MapGestureViewFactory(
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
		return self.mapFactory.map
	}
}

extension MapFactoryProvider: IMapSnapshotterProvider {
	var snapshotter: IMapSnapshotter {
		return self.mapFactory.snapshotter
	}
}
