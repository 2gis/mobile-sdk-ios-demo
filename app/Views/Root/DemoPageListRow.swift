import SwiftUI

struct DemoPageListRow: View {
	let page: DemoPage

	var body: some View {
		HStack {
			Image(systemName: "circle.fill")
				.resizable()
				.frame(width: 10, height: 10)
			Text(page.name)
			Spacer()
		}
	}
}
