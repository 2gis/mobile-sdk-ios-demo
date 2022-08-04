import UIKit

public final class MapMarkerView: UIView {
	private enum Constants {
		static let labelOffset: CGFloat = 10
		static let labelMaxWidth: CGFloat = 200
		static let titleBlizzardColor = UIColor(named: "MarkerTitle")
		static let titleFont = UIFont.systemFont(ofSize: 18, weight:.bold)
		static let subtitleGrayColor = UIColor(named: "MarkerSubtitle")
		static let subtitleFont = UIFont.systemFont(ofSize: 15, weight: .regular)
		static let markerRadius: CGFloat = 15
		static let markerShadowOffset = CGSize(width: -2.0, height: -2.0)
		static let markerShadowOpacity: Float = 0.5
	}

	private let viewModel: MapMarkerViewModel

	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.textColor = Constants.titleBlizzardColor
		label.text = self.viewModel.title
		label.font = Constants.titleFont
		label.preferredMaxLayoutWidth = Constants.labelMaxWidth
		label.numberOfLines = 0
		return label
	}()

	private lazy var subtitleLabel: UILabel = {
		let label = UILabel()
		label.textColor = Constants.subtitleGrayColor
		label.text = self.viewModel.subtitle
		label.font = Constants.subtitleFont
		label.preferredMaxLayoutWidth = Constants.labelMaxWidth
		label.numberOfLines = 0
		return label
	}()

	init(viewModel: MapMarkerViewModel) {
		self.viewModel = viewModel
		super.init(frame: .zero)
		self.setupUI()
	}

	required init?(coder: NSCoder) {
		fatalError("Use init(viewModel:)")
	}

	public override var intrinsicContentSize: CGSize {
		CGSize(
			width: max(self.titleLabel.frame.width, self.subtitleLabel.frame.width),
			height: self.titleLabel.frame.height + self.subtitleLabel.frame.height
		)
	}

	private func setupUI() {
		self.setupView()
		self.setupTitleLabel()
		self.setupSubtitleLabel()
	}
}

private extension MapMarkerView {
	func setupView() {
		self.translatesAutoresizingMaskIntoConstraints = false

		self.layer.cornerRadius = Constants.markerRadius
		self.layer.shadowColor = UIColor.black.cgColor
		self.layer.shadowOffset = Constants.markerShadowOffset
		self.layer.shadowRadius = Constants.markerRadius
		self.layer.shadowOpacity = Constants.markerShadowOpacity
		self.backgroundColor = UIColor.white

		NSLayoutConstraint.activate([
			self.widthAnchor.constraint(lessThanOrEqualToConstant: Constants.labelMaxWidth)
		])
	}

	func setupTitleLabel() {
		self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.titleLabel.sizeToFit()
		self.addSubview(self.titleLabel)

		NSLayoutConstraint.activate([
			self.titleLabel.leftAnchor.constraint(
				equalTo: self.leftAnchor,
				constant: Constants.labelOffset
			),
			self.titleLabel.rightAnchor.constraint(
				equalTo: self.rightAnchor,
				constant: -Constants.labelOffset
			),
			self.titleLabel.topAnchor.constraint(
				equalTo: self.topAnchor,
				constant: Constants.labelOffset
			)
		])
	}

	func setupSubtitleLabel() {
		self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
		self.subtitleLabel.sizeToFit()
		self.addSubview(self.subtitleLabel)

		NSLayoutConstraint.activate([
			self.subtitleLabel.leftAnchor.constraint(
				equalTo: self.leftAnchor,
				constant: Constants.labelOffset
			),
			self.subtitleLabel.rightAnchor.constraint(
				equalTo: self.rightAnchor,
				constant: -Constants.labelOffset
			),
			self.subtitleLabel.topAnchor.constraint(
				equalTo: self.titleLabel.bottomAnchor,
				constant: Constants.labelOffset
			),
			self.subtitleLabel.bottomAnchor.constraint(
				equalTo: self.bottomAnchor,
				constant: -Constants.labelOffset
			)
		])
	}
}
