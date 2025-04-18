import UIKit

final class NavigatorSettingsUIView: UIView {
	private let viewModel: NavigatorSettingsViewModel

	private let titleLabel: UILabel = {
		let label = UILabel()
		label.text = "Navigation settings:"
		label.font = .boldSystemFont(ofSize: 18)
		label.textAlignment = .center
		return label
	}()

	private var freeRoamStack: UIStackView!
	private var simulationStack: UIStackView!
	private var simulationSpeedStack: UIStackView!
	private var speedExcessStack: UIStackView!
	private var routeTypeStack: UIStackView!
	private var followControllerTypeStack: UIStackView!

	private let freeRoamSwitch = UISwitch()
	private let freeRoamLabel: UILabel = {
		let label = UILabel()
		label.text = "Freeroam"
		return label
	}()

	private let simulationSwitch = UISwitch()
	private let simulationLabel: UILabel = {
		let label = UILabel()
		label.text = "Simulation"
		return label
	}()

	private let speedContainer = UIStackView()

	private let speedExcessLabel = UILabel()
	private lazy var speedExcessStepper: UIStepper = {
		let stepper = UIStepper()
		stepper.minimumValue = -20
		stepper.maximumValue = Double(self.viewModel.maxAllowableSpeedExcessKmH)
		return stepper
	}()

	private let simulationSpeedLabel = UILabel()
	private lazy var simulationSpeedStepper: UIStepper = {
		let stepper = UIStepper()
		stepper.minimumValue = 0
		stepper.maximumValue = self.viewModel.maxSimulationSpeedKmH
		return stepper
	}()

	private lazy var routeTypeLabel: UILabel = {
		let label = UILabel()
		label.text = "Route type"
		label.font = .boldSystemFont(ofSize: 18)
		return label
	}()

	private lazy var routeTypeSegmentedControl: UISegmentedControl = {
		let segmentedControl = UISegmentedControl(items: self.viewModel.routeTypeSources.map(\.name))
		segmentedControl.selectedSegmentIndex = self.viewModel.routeTypeSources.firstIndex(of: self.viewModel.routeType) ?? 0
		segmentedControl.addTarget(
			self,
			action: #selector(self.routeTypeChanged),
			for: .valueChanged
		)
		return segmentedControl
	}()

	private lazy var followControllerTypeLabel: UILabel = {
		let label = UILabel()
		label.text = "Follow controller type"
		label.font = .boldSystemFont(ofSize: 18)
		return label
	}()

	private lazy var followControllerTypeSegmentedControl: UISegmentedControl = {
		let segmentedControl = UISegmentedControl(items: self.viewModel.styleZoomFollowControllerTypes.map(\.name))
		segmentedControl.selectedSegmentIndex = self.viewModel.styleZoomFollowControllerTypes.firstIndex(of: self.viewModel.styleZoomFollowControllerType) ?? 0
		segmentedControl.addTarget(
			self,
			action: #selector(self.routeTypeChanged),
			for: .valueChanged
		)
		return segmentedControl
	}()

	private let cancelButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Cancel", for: .normal)
		button.titleLabel?.font = .boldSystemFont(ofSize: 16)
		return button
	}()

	private let goButton: UIButton = {
		let button = UIButton(type: .system)
		button.setTitle("Go!", for: .normal)
		button.titleLabel?.font = .boldSystemFont(ofSize: 16)
		return button
	}()

	private var onGoTapped: (() -> Void)?
	private var onCancelTapped: (() -> Void)?

	init(
		viewModel: NavigatorSettingsViewModel,
		onGoTapped: @escaping () -> Void,
		onCancelTapped: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.onGoTapped = onGoTapped
		self.onCancelTapped = onCancelTapped
		super.init(frame: .zero)

		self.freeRoamSwitch.isOn = viewModel.isFreeRoam
		self.freeRoamSwitch.addTarget(self, action: #selector(self.freeRoamSwitchChanged), for: .valueChanged)
		self.simulationSwitch.isOn = viewModel.isSimulation
		self.simulationSwitch.addTarget(self, action: #selector(self.simulationSwitchChanged), for: .valueChanged)

		self.freeRoamStack = self.createStackView(label: self.freeRoamLabel, control: self.freeRoamSwitch, axis: .horizontal)
		self.simulationStack = self.createStackView(label: self.simulationLabel, control: self.simulationSwitch, axis: .horizontal)
		self.simulationSpeedStack = self.createStackView(label: self.simulationSpeedLabel, control: self.simulationSpeedStepper, axis: .horizontal)
		self.speedExcessStack = self.createStackView(label: self.speedExcessLabel, control: self.speedExcessStepper, axis: .horizontal)
		self.routeTypeStack = self.createStackView(label: self.routeTypeLabel, control: self.routeTypeSegmentedControl, axis: .vertical)
		self.followControllerTypeStack = self.createStackView(label: self.followControllerTypeLabel, control: self.followControllerTypeSegmentedControl, axis: .vertical)

		self.setupUI()
		self.setupActions()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupUI() {
		backgroundColor = .systemBackground
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.3
		layer.shadowOffset = .zero
		layer.shadowRadius = 10
		layer.cornerRadius = 12

		let scrollView = UIScrollView()
		scrollView.showsHorizontalScrollIndicator = false
		scrollView.showsVerticalScrollIndicator = false
		scrollView.translatesAutoresizingMaskIntoConstraints = false
		addSubview(scrollView)

		let stackView = UIStackView(arrangedSubviews: [titleLabel] + [
			freeRoamStack,
			simulationStack,
			simulationSpeedStack,
			speedExcessStack,
			routeTypeStack,
			followControllerTypeStack,
		].compactMap { $0 } + [self.createButtonRow()])
		stackView.axis = .vertical
		stackView.spacing = 10
		stackView.translatesAutoresizingMaskIntoConstraints = false
		scrollView.addSubview(stackView)

		NSLayoutConstraint.activate([
			scrollView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
			scrollView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
			scrollView.topAnchor.constraint(equalTo: topAnchor, constant: 20),
			scrollView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -20),

			stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
			stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
			stackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -5),
		])

		self.configureStepper(self.speedExcessLabel, self.speedExcessStepper, textFormat: "Permissible speeding\n%.0f km/h", value: Double(self.viewModel.allowableSpeedExcessKmH))
		self.speedExcessStepper.addTarget(self, action: #selector(self.speedExcessChanged), for: .valueChanged)
		self.configureStepper(self.simulationSpeedLabel, self.simulationSpeedStepper, textFormat: "Speed %.0f km/h", value: Double(self.viewModel.simulationSpeedKmH))
		self.simulationSpeedStepper.addTarget(self, action: #selector(self.simulationSpeedChanged), for: .valueChanged)

		self.simulationSpeedStack.isHidden = !(self.viewModel.isSimulation && !self.viewModel.isFreeRoam)
	}

	private func setupActions() {
		self.cancelButton.addTarget(self, action: #selector(self.cancelTapped), for: .touchUpInside)
		self.goButton.addTarget(self, action: #selector(self.goTapped), for: .touchUpInside)
	}

	@objc private func cancelTapped() {
		self.onCancelTapped?()
	}

	@objc private func goTapped() {
		self.onGoTapped?()
	}

	@objc private func freeRoamSwitchChanged() {
		self.viewModel.isFreeRoam = self.freeRoamSwitch.isOn
		self.updateSimulationVisibility()
	}

	@objc private func simulationSwitchChanged() {
		self.viewModel.isSimulation = self.simulationSwitch.isOn
		self.updateSimulationVisibility()
	}

	@objc private func routeTypeChanged() {
		let index = self.routeTypeSegmentedControl.selectedSegmentIndex
		self.viewModel.routeType = self.viewModel.routeTypeSources[index]
	}

	@objc private func followControllerTypeChanged() {
		let index = self.followControllerTypeSegmentedControl.selectedSegmentIndex
		self.viewModel.styleZoomFollowControllerType = self.viewModel.styleZoomFollowControllerTypes[index]
	}

	private func updateSimulationVisibility() {
		self.simulationStack.isHidden = self.viewModel.isFreeRoam
		self.simulationSpeedStack.isHidden = !(self.viewModel.isSimulation && !self.viewModel.isFreeRoam)
	}

	@objc private func speedExcessChanged() {
		self.viewModel.allowableSpeedExcessKmH = Float(self.speedExcessStepper.value)
		self.speedExcessLabel.text = "Permissible speeding\n\(Int(self.viewModel.allowableSpeedExcessKmH)) km/h"
	}

	@objc private func simulationSpeedChanged() {
		self.viewModel.simulationSpeedKmH = self.simulationSpeedStepper.value
		self.simulationSpeedLabel.text = "Speed \(Int(self.viewModel.simulationSpeedKmH)) km/h"
	}

	private func createStackView(label: UILabel, control: UIView, axis: NSLayoutConstraint.Axis) -> UIStackView {
		let stackView = UIStackView(arrangedSubviews: [label, control])
		let alignment: UIStackView.Alignment = axis == .vertical ? .leading : .center
		stackView.axis = axis
		stackView.spacing = 10
		stackView.alignment = alignment
		stackView.distribution = .equalCentering

		if let control = control as? UISegmentedControl {
			control.setContentHuggingPriority(.defaultLow, for: .horizontal)
			control.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
			control.translatesAutoresizingMaskIntoConstraints = false
			control.widthAnchor.constraint(equalTo: stackView.widthAnchor).isActive = true
		}

		return stackView
	}

	private func createButtonRow() -> UIStackView {
		let stackView = UIStackView(arrangedSubviews: [cancelButton, goButton])
		stackView.axis = .horizontal
		stackView.spacing = 20
		stackView.alignment = .center
		stackView.distribution = .equalCentering
		return stackView
	}

	private func configureStepper(_ label: UILabel, _ stepper: UIStepper, textFormat: String, value: Double) {
		label.text = String(format: textFormat, value)
		label.numberOfLines = 0
		label.lineBreakMode = .byWordWrapping
		stepper.value = value
	}
}
