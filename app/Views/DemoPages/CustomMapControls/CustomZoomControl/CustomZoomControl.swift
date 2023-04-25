import UIKit
import DGis

/// Блок управления масштабом карты.
public final class CustomZoomControl: UIControl {
	public static override var requiresConstraintBasedLayout: Bool { true }
	private let stack: UIStackView

	init(map: Map) {
		let model = ZoomControlModel(map: map)

		let zoomIn = ZoomButton(model: model, direction: .zoomIn)
		let zoomInImage = UIImage(systemName: "plus.magnifyingglass")
		zoomIn.setImage(zoomInImage, for: .normal)

		let zoomOut = ZoomButton(model: model, direction: .zoomOut)
		let zoomOutImage = UIImage(systemName: "minus.magnifyingglass")
		zoomOut.setImage(zoomOutImage, for: .normal)

		self.stack = UIStackView(arrangedSubviews: [zoomIn, zoomOut])
		self.stack.distribution = .fillEqually
		self.stack.alignment = .fill
		self.stack.axis = .vertical

		super.init(frame: .zero)

		self.addSubview(self.stack)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("Use init(map:)")
	}

	public override func layoutSubviews() {
		super.layoutSubviews()
		self.stack.frame = self.bounds
	}
}

private final class ZoomButton: UIButton {
	private let model: ZoomControlModel
	private let direction: ZoomControlButton
	private var connection: ICancellable = NoopCancellable()

	init(model: ZoomControlModel, direction: ZoomControlButton) {
		self.model = model
		self.direction = direction

		super.init(frame: .zero)

		self.contentVerticalAlignment = .fill
		self.contentHorizontalAlignment = .fill

		self.addTarget(
			self,
			action: #selector(self.startZoom),
			for: .touchDown
		)
		self.addTarget(
			self,
			action: #selector(self.stopZoom),
			for: [.touchCancel, .touchUpInside, .touchUpOutside]
		)

		self.connection = self.model.isEnabled(button: self.direction).sink {
			[weak self] isEnabled in
			DispatchQueue.main.async {
				self?.isEnabled = isEnabled
			}
		}
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	@objc private func startZoom() {
		UIView.animate(
			withDuration: 0.25,
			delay: 0,
			usingSpringWithDamping: 1,
			initialSpringVelocity: 5,
			animations: {
				self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
			})
		self.model.setPressed(button: self.direction, value: true)
	}

	@objc private func stopZoom() {
		UIView.animate(
			withDuration: 0.25,
			delay: 0,
			usingSpringWithDamping: 0.5,
			initialSpringVelocity: 5,
			animations: {
				self.transform = CGAffineTransform.identity
			})
		self.model.setPressed(button: self.direction, value: false)
	}
}
