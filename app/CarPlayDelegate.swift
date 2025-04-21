import CarPlay

final class CarPlayDelegate: NSObject {
	private var carPlayController: CarPlayController?
}

// MARK: - CPTemplateApplicationSceneDelegate
extension CarPlayDelegate: CPTemplateApplicationSceneDelegate {

	func templateApplicationScene(
		_ templateApplicationScene: CPTemplateApplicationScene,
		didConnect interfaceController: CPInterfaceController,
		to window: CPWindow
	) {
		let carPlayController = CarPlayController(interfaceController: interfaceController)
		window.rootViewController = carPlayController
		self.carPlayController = carPlayController
		window.makeKeyAndVisible()
	}

	func templateApplicationScene(
		_ templateApplicationScene: CPTemplateApplicationScene,
		didDisconnectInterfaceController interfaceController: CPInterfaceController
	) {
	}

}

// MARK: - UISceneDelegate
extension CarPlayDelegate {

}
