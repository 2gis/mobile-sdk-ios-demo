import SwiftUI

extension UIApplication {
	var keyWindow: UIWindow? {
		let keyWindow = UIApplication.shared.connectedScenes
			.filter({$0.activationState == .foregroundActive})
			.map({$0 as? UIWindowScene})
			.compactMap({$0})
			.first?.windows
			.filter({$0.isKeyWindow}).first
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
}
