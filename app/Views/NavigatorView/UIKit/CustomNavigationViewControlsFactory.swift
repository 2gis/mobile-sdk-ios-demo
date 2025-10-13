import UIKit
import DGis

class CustomNavigationViewControlsFactory: INavigationUIControlsFactory {
	let navigationViewControlsFactory: INavigationUIControlsFactory

	init(navigationViewControlsFactory: INavigationUIControlsFactory) {
		self.navigationViewControlsFactory = navigationViewControlsFactory
	}

	/// UI element with information about the next maneuver and additional maneuver.
	/// See `RouteInstruction`, `RouteInstruction.extraInstructionInfo`, `getInstructionManeuver`.
	func makeNextManeuverUIControl(uiModel: DGis.Model) -> UIView & DGis.INextManeuverUIControl {
		return self.navigationViewControlsFactory.makeNextManeuverUIControl(uiModel: uiModel)
	}

	/// UI element with information about the current speed, speed limit on the current route segment, and camera zone warning.
	/// See `Model.currentSpeed`, `Model.maxSpeedLimit`, and `Model.cameraProgress`.
	func makeSpeedUIControl(uiModel: DGis.Model) -> (UIView & DGis.INavigationUIControl) {
		return navigationViewControlsFactory.makeSpeedUIControl(uiModel: uiModel)
	}

	/// UI element with information about the remaining distance and estimated time of arrival/remaining travel time.
	/// See `Model.duration`, `Model.routeDuration`, and `DistanceCounters`.
	func makeRemainingRouteInfoUIControl(navigationManager: DGis.NavigationManager) -> UIView & DGis.INavigationUIControl {
		return navigationViewControlsFactory.makeRemainingRouteInfoUIControl(navigationManager: navigationManager)
	}

	/// UI element for displaying navigation status messages, such as route searching and GPS signal loss.
	/// See `Model.state` and `Model.badLocation`.
	func makeMessageBarUIControl(uiModel: DGis.Model) -> UIView & DGis.INavigationUIControl {
		let control = navigationViewControlsFactory.makeMessageBarUIControl(uiModel: uiModel)

		if !uiModel.locationAvailable {
			let badLocationView = BadLocationUIView(frame: .zero)
			badLocationView.backgroundColor = .magenta
			return badLocationView
		} else {
			return control
		}
	}

	/// UI element for switching to a route with a shorter estimated arrival time.
	/// See `Model.betterRoute`.
	func makeBetterRouteUIControl(uiModel: DGis.Model) -> UIView & DGis.INavigationUIControl {
		return navigationViewControlsFactory.makeBetterRouteUIControl(uiModel: uiModel)
	}

	/// UI element for displaying vehicle speeds and road events along the route.
	/// See `Model.dynamicRouteInfo`.
	func makeThermometerUIControl(uiModel: DGis.Model) -> UIView & DGis.IThermometerUIControl {
		return navigationViewControlsFactory.makeThermometerUIControl(uiModel: uiModel)
	}
}

class BadLocationUIView: UIView & DGis.INavigationUIControl {
	/// Visibility of the element.
	public var isVisible = true
	/// Signal for visibility change.
	var onDidChangeVisibility: (() -> Void)?

	private lazy var infoLabel: UILabel = {
		let label = UILabel()
		label.numberOfLines = 3
		return label
	}()

	override init(
		frame: CGRect = .zero
	) {
		super.init(frame: frame)
		self.setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	func setupUI() {
		self.infoLabel.translatesAutoresizingMaskIntoConstraints = false
		self.addSubview(self.infoLabel)
		NSLayoutConstraint.activate([
			self.infoLabel.topAnchor.constraint(equalTo: self.topAnchor),
			self.infoLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			self.infoLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			self.infoLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor)])

		let attributes = [
			NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
			NSAttributedString.Key.backgroundColor: UIColor.blue
		]
		self.infoLabel.attributedText = NSAttributedString(
			string: "Lost position exactly and forever",
			attributes: attributes
		)
	}
}
