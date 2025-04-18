import UIKit
import DGis

class CustomNavigationViewControlsFactory: INavigationViewControlsFactory {
	let navigationViewControlsFactory: INavigationViewControlsFactory

	init(navigationViewControlsFactory: INavigationViewControlsFactory) {
		self.navigationViewControlsFactory = navigationViewControlsFactory
	}

	/// UI элемент с информацией о следующем манёвре и дополнительном манёвре.
	/// См. `RouteInstruction`, `RouteInstruction.extraInstructionInfo`, `getInstructionManeuver`.
	func makeNextManeuverControl(uiModel: DGis.Model) -> UIView & DGis.INextManeuverControlView {
		return navigationViewControlsFactory.makeNextManeuverControl(uiModel: uiModel)
	}

	/// UI элемент с информацией о текущей скорости движения, ограничении скорости на текущем участке маршрута и предупреждении о прохождении зоны действия камеры.
    /// См. `Model.currentSpeed`, `Model.maxSpeedLimit` и `Model.cameraProgress`.
	func makeSpeedControl(uiModel: DGis.Model) -> (UIView & DGis.INavigationControlView) {
		return navigationViewControlsFactory.makeSpeedControl(uiModel: uiModel)
	}

	/// UI элемент с информацией об оставшемся расстоянии и ориентировочном времени прибытия/оставшемся времени в пути.
    /// См. `Model.duration`, `Model.routeDuration` и `DistanceCounters`.
	func makeRemainingRouteInfoControl(navigationManager: DGis.NavigationManager) -> UIView & DGis.INavigationControlView {
		return navigationViewControlsFactory.makeRemainingRouteInfoControl(navigationManager: navigationManager)
	}

	/// UI элемент для отображения сообщений о статусе навигации, например, о поиске маршрута и потере сигнала GPS.
    /// См. `Model.state` и `Model.badLocation`.
	func makeMessageBarControl(uiModel: DGis.Model) -> UIView & DGis.INavigationControlView {
		let control = navigationViewControlsFactory.makeMessageBarControl(uiModel: uiModel)

		if !uiModel.locationAvailable {
			let badLocationView = BadLocationView(frame: .zero)
			badLocationView.backgroundColor = .magenta
			return badLocationView
		} else {
			return control
		}
    }

	/// UI элемент перехода на маршрут с меньшим ожидаемым временем прибытия.
    /// См. `Model.betterRoute`.
	func makeBetterRouteControl(uiModel: DGis.Model) -> UIView & DGis.INavigationControlView {
		return navigationViewControlsFactory.makeBetterRouteControl(uiModel: uiModel)
    }

	/// UI элемент для отображения скоростей движения ТС и дорожных событий на маршруте.
    /// См. `Model.dynamicRouteInfo`.
	func makeThermometerControl(uiModel: DGis.Model) -> UIView & DGis.IThermometerControlView {
		return navigationViewControlsFactory.makeThermometerControl(uiModel: uiModel)
	}
}

class BadLocationView: UIView & DGis.INavigationControlView {
	/// Видимость элемента.
	public var isVisible = true
	/// Сигнал изменения видимости элемента.
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
