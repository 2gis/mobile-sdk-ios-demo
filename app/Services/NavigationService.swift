import Combine
import SwiftUI

@MainActor
class NavigationService: ObservableObject {
	private var keyWindows: [UIWindow] {
		UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.flatMap(\.windows)
			.sorted { a, _ in a.isKeyWindow }
	}

	private var topNavigationController: UINavigationController? {
		self.keyWindows
			.lazy
			.compactMap(\.topNavigationController)
			.first
	}

	private var topViewController: UIViewController? {
		self.keyWindows
			.lazy
			.compactMap(\.topViewController)
			.first
	}

	func present(_ viewController: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
		guard let topVC = self.topViewController else {
			completion?()
			return
		}
		topVC.present(viewController, animated: animated, completion: completion)
	}

	func present(
		_ view: some View,
		animated: Bool = true,
		completion: (() -> Void)? = nil
	) {
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

	func push(_ view: some View, animated: Bool = true) {
		self.push(UIHostingController(rootView: view), animated: animated)
	}

	func pop(animated: Bool = true) {
		self.topNavigationController?.popViewController(animated: animated)
	}

	func popToRoot(animated: Bool = true) {
		self.topNavigationController?.popToRootViewController(animated: animated)
	}
}
