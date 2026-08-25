import UIKit
import DGis

class CustomNavigationMapUIControlsFactory: INavigationMapUIControlsFactory {
	private let mapControlsFactory: IMapUIControlsFactory
	internal var followManager: INavigatorFollowManager
	private let navigationMapControlsFactory: INavigationMapUIControlsFactory

	init(
		mapFactory: IMapFactory,
		navigationViewFactory: INavigationUIViewFactory
	) {
		self.mapControlsFactory = mapFactory.mapUIControlsFactory
		let map = mapFactory.map
		self.followManager = NavigatorFollowManager(map: map, followMode: .none)
		self.navigationMapControlsFactory = navigationViewFactory.makeNavigationMapUIControlsFactory(
			map: map,
			followManager: self.followManager
		)
	}

	func makeZoomUIControl() -> UIControl {
		self.mapControlsFactory.makeZoomUIControl()
	}

	func makeTrafficAndParkingMapUIControl() -> UIControl {
		self.navigationMapControlsFactory.makeParkingUIControl()
	}
	
	func makeTrafficUIControl() -> UIControl {
		self.navigationMapControlsFactory.makeTrafficUIControl()
	}
	
	func makeParkingUIControl() -> UIControl {
		self.navigationMapControlsFactory.makeParkingUIControl()
	}

	func makeCompassUIControl(icon: UIImage? = nil, highlightedIcon: UIImage? = nil) -> UIControl {
		self.navigationMapControlsFactory.makeCompassUIControl(
			icon: UIImage(named: "svg/compass"),
			highlightedIcon: UIImage(named: "svg/compass_highlighted")
		)
	}

	func makeNavigationFollowingUIControl() -> NavigationFollowingUIControl {
		self.navigationMapControlsFactory.makeNavigationFollowingUIControl()
	}

	func makeTUGCUIControl() -> UIControl {
		self.navigationMapControlsFactory.makeTUGCUIControl()
	}

	func makeIndoorUIControl() -> IndoorUIControl {
		self.mapControlsFactory.makeIndoorUIControl(.default)
	}
}
