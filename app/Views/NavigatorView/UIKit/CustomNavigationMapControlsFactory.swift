import DGis
import UIKit

final class CustomNavigationMapUIControlsFactory: IMapUIControlsFactory {
	private let mapControlsFactory: IMapUIControlsFactory

	init(
		mapFactory: IMapFactory,
		theme: MapControlsTheme
	) {
		self.mapControlsFactory = mapFactory.makeMapUIControlsFactory(theme: theme)
	}

	func makeZoomUIControl() -> UIControl {
		self.mapControlsFactory.makeZoomUIControl()
	}

	func makeCurrentLocationUIControl(permissionCallback: @escaping () -> Void) -> UIControl {
		self.mapControlsFactory.makeCurrentLocationUIControl(permissionCallback: permissionCallback)
	}

	func makeRoadEventCreatorButtonUIControl(action: @escaping () -> Void) -> UIControl {
		self.mapControlsFactory.makeRoadEventCreatorButtonUIControl(action: action)
	}

	func makeCompassUIControl() -> UIControl {
		self.mapControlsFactory.makeCompassUIControl()
	}

	func makeTrafficUIControl() -> UIControl {
		self.mapControlsFactory.makeTrafficUIControl()
	}

	func makeParkingUIControl() -> UIControl {
		self.mapControlsFactory.makeParkingUIControl()
	}

	func makeTrafficAndParkingUIControl() -> UIControl {
		self.mapControlsFactory.makeTrafficAndParkingUIControl()
	}

	func makeIndoorUIControl(showOverview: Bool) -> UIView {
		self.mapControlsFactory.makeIndoorUIControl(showOverview: showOverview)
	}
}
