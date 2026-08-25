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
		let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
		let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)

		return self
			.onReceive(willShow) { note in
				Task { @MainActor in
					guard let keyboardFrame = note.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
					let keyboardHeight = keyboardFrame.height
					let bottomInset = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
					offset.wrappedValue = keyboardHeight - bottomInset
				}
			}
			.onReceive(willHide) { _ in
				offset.wrappedValue = 0
			}
			.animation(.easeInOut, value: offset.wrappedValue)
			.padding(.bottom, offset.wrappedValue)
	}

#if canImport(UIKit)
	// Sometimes you need to force close the keyboard and unfocus all text fields. This simple function does just that
	func hideKeyboard() {
		UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
#endif
}
