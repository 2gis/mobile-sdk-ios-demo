import DGis
import UIKit

final class FullScreenMapViewController: UIViewController {
	private let mapView: IMapUIView & UIView

	init(mapView: IMapUIView & UIView) {
		self.mapView = mapView
		super.init(nibName: nil, bundle: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("Use init(mapView:)")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.mapView.translatesAutoresizingMaskIntoConstraints = false
		self.view.addSubview(self.mapView)
		NSLayoutConstraint.activate([
			self.mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor),
			self.mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor),
			self.mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
			self.mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
		])
		let dismissButton = UIButton()
		dismissButton.backgroundColor = .gray
		dismissButton.translatesAutoresizingMaskIntoConstraints = false
		dismissButton.setTitle("Close", for: .normal)
		self.view.addSubview(dismissButton)
		NSLayoutConstraint.activate([
			dismissButton.leftAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leftAnchor),
			dismissButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
			dismissButton.heightAnchor.constraint(equalToConstant: 44),
			dismissButton.widthAnchor.constraint(equalToConstant: 100),
		])
		dismissButton.addTarget(self, action: #selector(self.dismissButtonTapped), for: .touchUpInside)
	}

	@objc private func dismissButtonTapped() {
		self.dismiss(animated: true, completion: nil)
	}
}
