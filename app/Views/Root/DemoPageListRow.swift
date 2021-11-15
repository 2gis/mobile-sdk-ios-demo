import SwiftUI

struct DemoPageListRow: View {
	let page: DemoPage
	let action: () -> Void

	var body: some View {
		Button {
			self.action()
		} label: {
			HStack {
				Image(systemName: "circle.fill")
				.resizable()
				.frame(width: 10, height: 10)
				Text(self.page.name)
				Spacer()
			}
		}.foregroundColor(
			Color(
				UIColor(dynamicProvider: { traitCollection in
					switch traitCollection.userInterfaceStyle {
						case .dark:
							return .white
						case .light, .unspecified:
							return .black
						@unknown default:
							return .black
					}
				})
			)
		)
	}
}
