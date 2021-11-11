import UIKit

extension UIWindow {
	var topViewController: UIViewController? {
		return self.findTopViewController(in: self.rootViewController)
	}

	var topNavigationController: UINavigationController? {
		return self.findNavigationController(in: self.rootViewController)
	}

	private func findTopViewController(in controller: UIViewController?) -> UIViewController? {
		if let navigationController = controller as? UINavigationController {
			return self.findTopViewController(in: navigationController.topViewController)
		} else if let tabController = controller as? UITabBarController,
				  let selected = tabController.selectedViewController {
			return self.findTopViewController(in: selected)
		} else if let presented = controller?.presentedViewController {
			return self.findTopViewController(in: presented)
		}
		return controller
	}

	private func findNavigationController(in controller: UIViewController?) -> UINavigationController? {
		if let presented = controller?.presentedViewController {
			return self.findNavigationController(in: presented)
		} else if let navigationController = controller as? UINavigationController {
			return navigationController
		} else if let tabController = controller as? UITabBarController,
				  let selected = tabController.selectedViewController {
			return self.findNavigationController(in: selected)
		} else {
			let navigationController = controller?.children.compactMap { $0 as? UINavigationController }
			return navigationController?.first
		}
	}
}
