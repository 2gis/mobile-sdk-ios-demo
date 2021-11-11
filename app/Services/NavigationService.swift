import SwiftUI

class NavigationService: ObservableObject {
	private var keyWindows: [UIWindow] {
		UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap { $0.windows }
			.sorted { a, _ in a.isKeyWindow }
	}

	private var topNavigationController: UINavigationController? {
		return self.keyWindows
			.lazy
			.compactMap { $0.topNavigationController }
			.first
	}

	private var topViewController: UIViewController? {
		return self.keyWindows
			.lazy
			.compactMap { $0.topViewController }
			.first
	}

	func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
		guard let topVC = self.topViewController else {
			completion?()
			return
		}
		topVC.present(viewController, animated: animated, completion: completion)
	}

	func present<Content>(
		_ view: Content,
		animated: Bool = true,
		completion: (() -> Void)? = nil
	) where Content : View {
		self.present(UIHostingController(rootView: view), animated: animated, completion: completion)
	}

	func dismiss(animated: Bool = true, completion: (() -> Void)?) {
		guard let topVC = self.topViewController else {
			completion?()
			return
		}
		topVC.dismiss(animated: animated, completion: completion)
	}

	func push(_ viewController: UIViewController, animated: Bool = true) {
		self.topNavigationController?.pushViewController(viewController, animated: animated)
	}

	func push<Content>(_ view: Content, animated: Bool = true) where Content : View {
		self.push(UIHostingController(rootView: view), animated: animated)
	}

	func pop(animated: Bool = true) {
		self.topNavigationController?.popViewController(animated: animated)
	}

	func popToRoot(animated: Bool = true) {
		self.topNavigationController?.popToRootViewController(animated: animated)
	}
}
