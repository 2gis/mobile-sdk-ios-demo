import UIKit
import DGis

class CustomNavigationMapControlsFactory: INavigationMapControlsFactory {
	var followManager: INavigatorFollowManager {
		self._followManager
	}

	private let mapControlFactory: IMapControlFactory
	private let _followManager: INavigatorFollowManager
	private let navigationMapControlsFactory: INavigationMapControlsFactory

	init(
		mapFactory: IMapFactory,
		navigationViewFactory: INavigationViewFactory
	) {
		self.mapControlFactory = mapFactory.mapControlFactory
		let map = mapFactory.map
		self._followManager = NavigatorFollowManager(map: map, followMode: .none)
		self.navigationMapControlsFactory = navigationViewFactory.makeNavigationMapControlsFactory(
			map: map,
			followManager: self._followManager
		)
	}

	func makeZoomControl() -> UIControl {
		self.mapControlFactory.makeZoomControl()
	}

	func makeTrafficAndParkingMapControl() -> UIControl {
		self.navigationMapControlsFactory.makeParkingControl()
	}
	
	func makeTrafficControl() -> UIControl {
		self.navigationMapControlsFactory.makeTrafficControl()
	}
	
	func makeParkingControl() -> UIControl {
		self.navigationMapControlsFactory.makeParkingControl()
	}

	func makeCompassControl(icon: UIImage? = nil, highlightedIcon: UIImage? = nil) -> UIControl {
		self.navigationMapControlsFactory.makeCompassControl(
			icon: UIImage(named: "svg/compass"),
			highlightedIcon: UIImage(named: "svg/compass_highlighted")
		)
	}

	func makeNavigationFollowingControl() -> NavigationFollowingControl {
		self.navigationMapControlsFactory.makeNavigationFollowingControl()
	}

	func makeTUGCControl() -> UIControl {
		self.navigationMapControlsFactory.makeTUGCControl()
	}

	func makeIndoorControl() -> IndoorControl {
		self.mapControlFactory.makeIndoorControl(.default)
	}
}
