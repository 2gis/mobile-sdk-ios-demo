import SwiftUI

extension UIApplication {
	var keyWindow: UIWindow? {
		let keyWindow = UIApplication.shared.connectedScenes
			.compactMap { $0 as? UIWindowScene }
			.first(where: { $0.activationState == .foregroundActive })?
			.windows
			.first(where: { $0.isKeyWindow })
		return keyWindow
	}
}

extension View {

	func followKeyboard(_ offset: Binding<CGFloat>) -> some View {

		return self
			.padding(.bottom, offset.wrappedValue)
			.animation(.easeInOut)
			.onAppear {

				NotificationCenter.default.addObserver(
					forName: UIResponder.keyboardWillShowNotification,
					object: nil,
					queue: .main
				) {
					guard let keyboardFrame = $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
					let keyboardHeight = keyboardFrame.height
					let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
					offset.wrappedValue = keyboardHeight - bottomInset
				}

				NotificationCenter.default.addObserver(
					forName: UIResponder.keyboardWillHideNotification,
					object: nil, queue: .main
				) { _ in
					offset.wrappedValue = 0
				}
			}
	}

	#if canImport(UIKit)
	//Sometimes you need to force close the keyboard and unfocus all text fields. This simple function does just that
	func hideKeyboard() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
	#endif
}
