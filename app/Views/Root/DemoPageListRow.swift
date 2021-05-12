import SwiftUI

struct DemoPageListRow: View {
	let page: DemoPage

	var body: some View {
		HStack {
			Image(systemName: "circle.fill")
			Text(page.name)
			Spacer()
		}
	}
}
