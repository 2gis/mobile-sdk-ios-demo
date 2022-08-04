import SwiftUI

struct NavigatorTargetPointSearchOverlayView: View {
	@State private var isOptionsShown: Bool = false
	private let startNavigationCallback: () -> Void
	private let viewModel: NavigatorSettingsViewModel
	private let restoreNavigationCallback: () -> Void

	init(
		viewModel: NavigatorSettingsViewModel,
		startNavigationCallback: @escaping () -> Void,
		restoreNavigationCallback: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.startNavigationCallback = startNavigationCallback
		self.restoreNavigationCallback = restoreNavigationCallback
	}

	var body: some View {
		ZStack {
			if self.isOptionsShown {
				NavigatorSettingsView(
					viewModel: self.viewModel,
					startNavigationCallback: {
						self.startNavigationCallback()
						self.isOptionsShown = false
					},
					restoreNavigationCallback: {
						self.restoreNavigationCallback()
						self.isOptionsShown = false
					},
					cancelCallback: {
						self.isOptionsShown = false
					}
				)
				.frame(maxWidth: 350)
			} else {
				HStack {
					Button(action: {
						self.isOptionsShown = true
					}) {
						HStack {
							Text("Go here?")
							.fontWeight(.medium)
							.padding(.leading, 10)

							Image(systemName: "car.fill")
							.padding(.trailing, 10)
						}
						.frame(height: 40, alignment: .center)
						.background(Color.white)
						.cornerRadius(10)
						.shadow(radius: 3)
					}
				}
				.offset(y: -40)

				VStack(alignment: .center) {
					Image(systemName: "multiply")
					.font(Font.system(size: 20, weight: .bold))
					.foregroundColor(.red)
					.shadow(radius: 3, x: 1, y: 1)
				}
			}
		}
	}
}
