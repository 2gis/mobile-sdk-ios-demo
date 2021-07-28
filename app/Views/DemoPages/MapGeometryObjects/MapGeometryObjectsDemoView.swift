import SwiftUI

struct MapGeometryObjectsDemoView: View {
	@ObservedObject private var viewModel: MapGeometryObjectsDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: MapGeometryObjectsDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			self.viewFactory.makeMapViewWithZoomControl(alignment: .bottomLeft)
			self.settingsButton()
			.frame(width: 100, height: 100, alignment: .bottomTrailing)
		}
		.edgesIgnoringSafeArea(.all)
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "list.bullet") {
			self.viewModel.showActionSheet = true
		}
		.padding(.bottom, 40)
		.padding(.trailing, 20)
		.actionSheet(isPresented: self.$viewModel.showActionSheet) {
			ActionSheet(
				title: Text("Тестовые сценарии"),
				buttons: [
					.default(Text("Тест изменения точек полилинии")) {
						self.viewModel.startPolylineEditingTest()
					},
					.default(Text("Удалить все объекты на карте")) {
						self.viewModel.removeAllObjects()
					},
					.default(Text("Показать модальный экран")) {
						self.pushModalViewController()
					},
					.cancel(Text("Отмена"))
				]
			)
		}
	}

	private func pushModalViewController() {
		let presenter = UIApplication.shared.topmostVC
		let modalVC = FullScreenCoverViewController()
		modalVC.view.backgroundColor = .red
		modalVC.modalTransitionStyle = .crossDissolve
		modalVC.modalPresentationStyle = .currentContext
		presenter?.present(modalVC, animated: true, completion: nil)
	}
}

private extension UIApplication {
	var topmostVC: UIViewController? {
		guard
			let window = UIApplication.shared.connectedScenes
				.filter({$0.activationState == .foregroundActive})
				.compactMap({$0 as? UIWindowScene })
				.first?.windows.first(where: { $0.isKeyWindow }),
			let rootViewController = window.rootViewController else {
			return nil
		}

		var topController = rootViewController

		while let newTopController = topController.presentedViewController {
			topController = newTopController
		}

		return topController
	}
}

private class FullScreenCoverViewController: UIViewController {
	private lazy var dismissButton = UIButton()

	override func viewDidLoad() {
		super.viewDidLoad()

		self.dismissButton.setTitle("Закрыть", for: .normal)
		self.dismissButton.translatesAutoresizingMaskIntoConstraints = false
		self.dismissButton.addTarget(
			self,
			action: #selector(self.dismissButtonTapped), for: .touchUpInside
		)
		self.view.addSubview(self.dismissButton)
	}

	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		self.dismissButton.frame = self.view.bounds
	}

	@objc private func dismissButtonTapped() {
		self.dismiss(animated: true, completion: nil)
	}
}
