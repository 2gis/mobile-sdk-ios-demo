import UIKit

class ErrorViewController: UIViewController {
	private let errorText: String

	init(errorText: String) {
		self.errorText = errorText
		super.init(nibName: nil, bundle: nil)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = .white
		DispatchQueue.main.async {
			let alertController = UIAlertController(
				title: "Failed to create DGis.Container",
				message: self.errorText,
				preferredStyle: .alert
			)
			self.present(alertController, animated: true)
		}
	}
}
