import SwiftUI

struct SettingsFormDisclosureButton: View {
	let title: String
	let subtitle: String?
	let action: () -> Void

	init(title: String, subtitle: String? = nil, action: @escaping () -> Void) {
		self.title = title
		self.subtitle = subtitle
		self.action = action
	}

	var body: some View {
		Button(
			action: self.action,
			label: {
				VStack(alignment: .leading) {
					HStack {
						Text(self.title)
						.foregroundColor(.primaryTitle)

						Spacer()

						Image(systemName: "chevron.right")
						.font(.body)
					}
					if let subtitle = self.subtitle {
						Text(subtitle)
						.foregroundColor(Color(.systemGray))
					}
				}

			}
		)
	}
}

