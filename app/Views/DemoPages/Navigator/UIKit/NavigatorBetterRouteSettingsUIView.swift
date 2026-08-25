import DGis
import UIKit

final class NavigatorBetterRouteSettingsVC: UIViewController {
	var settings: NavigatorBetterRouteSettings

	init(
		settings: NavigatorBetterRouteSettings
	) {
		self.settings = settings
		super.init(nibName: nil, bundle: nil)
		self.setupView()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupView() {
		self.view.backgroundColor = .systemBackground

		let headerView = UIView()
		headerView.translatesAutoresizingMaskIntoConstraints = false

		let titleLabel = UILabel()
		titleLabel.text = "Alternative routes settings"
		titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
		titleLabel.translatesAutoresizingMaskIntoConstraints = false

		let closeButton = UIButton(type: .system)
		closeButton.setTitle("Close", for: .normal)
		closeButton.addTarget(self, action: #selector(self.closeTapped), for: .touchUpInside)
		closeButton.translatesAutoresizingMaskIntoConstraints = false

		headerView.addSubview(titleLabel)
		headerView.addSubview(closeButton)

		titleLabel.textAlignment = .center

		closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .regular)

		NSLayoutConstraint.activate([
			titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
			titleLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

			closeButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
			closeButton.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
		])

		self.view.addSubview(headerView)
		NSLayoutConstraint.activate([
			headerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 20),
			headerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
			headerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
			headerView.heightAnchor.constraint(equalToConstant: 44),
		])

		let stack = UIStackView()
		stack.axis = .vertical
		stack.spacing = 12
		stack.translatesAutoresizingMaskIntoConstraints = false

		stack.addArrangedSubview(SettingsFormTextFieldUIView(
			title: "Minimum time gain for an alternative route, seconds",
			initialValue: self.settings.betterRouteTimeCostThreshold,
			rawToValueConverter: { TimeInterval(floatLiteral: Double($0) ?? 0) },
			valueToRawConverter: { "\($0)" },
			onValueChanged: { self.settings.betterRouteTimeCostThreshold = $0 ?? TimeInterval.zero }
		))

		stack.addArrangedSubview(SettingsFormTextFieldUIView(
			title: "Minimum length gain for an alternative route, meters",
			initialValue: self.settings.betterRouteLengthThreshold,
			rawToValueConverter: { RouteDistance(millimeters: (Int64($0) ?? 0) * 1000) },
			valueToRawConverter: { "\($0.millimeters / 1000)" },
			onValueChanged: { self.settings.betterRouteLengthThreshold = $0 ?? RouteDistance(millimeters: 0) }
		))

		stack.addArrangedSubview(SettingsFormTextFieldUIView(
			title: "Timeout for alternative route search. Must be at least 5 seconds",
			initialValue: self.settings.routeSearchDefaultDelay,
			rawToValueConverter: { TimeInterval(floatLiteral: Double($0) ?? 0) },
			valueToRawConverter: { "\($0)" },
			onValueChanged: { self.settings.routeSearchDefaultDelay = $0 ?? TimeInterval(floatLiteral: 5.0) }
		))

		self.view.addSubview(stack)
		NSLayoutConstraint.activate([
			stack.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
			stack.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 20),
			stack.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),
			stack.bottomAnchor.constraint(lessThanOrEqualTo: self.view.bottomAnchor, constant: -20),
		])
	}

	@objc private func closeTapped() {
		self.dismiss(animated: true, completion: nil)
	}
}
