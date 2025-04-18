import SwiftUI

struct VisibleRectVisibleAreaInfoView: View {
	@Binding var isPresented: Bool
	var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 10) {
				Spacer()
				Text("Description:")
				.font(.headline)
				Text("VisibleArea ").bold()
				+ Text("is the projection of the camera onto the map, displayed as an ")
				+ Text("orange polygon\n\n").bold().foregroundColor(.orange)
				+ Text("VisibleRect ").bold()
				+ Text("is the smallest rectangle on the map that encloses the VisibleArea, displayed as a ")
				+ Text("green polygon").bold().foregroundColor(.green)
				Divider()
				HStack {
					Text("Visible Area Button:")
					self.visibleAreaButton
				}
				HStack {
					Text("Visible Rect Button:")
					self.visibleRectButton
				}
				Spacer()
			}
		}
	}
	
	private var visibleAreaButton: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 10)
			.foregroundColor(Color(UIColor.systemBackground))
			.frame(width: 55, height: 55)
			.shadow(radius: 5)
			Image(systemName: "arrowtriangle.down")
			.font(.largeTitle)
			.foregroundColor(.accentColor)
		}
	}
	
	private var visibleRectButton: some View {
		ZStack {
			RoundedRectangle(cornerRadius: 10)
			.foregroundColor(Color(UIColor.systemBackground))
			.frame(width: 55, height: 55)
			.shadow(radius: 5)
			Image(systemName: "arrowtriangle.down")
			.imageScale(.large)
			Image(systemName: "viewfinder")
			.imageScale(.large)
		}
		.font(.largeTitle)
		.foregroundColor(.accentColor)
	}
}
