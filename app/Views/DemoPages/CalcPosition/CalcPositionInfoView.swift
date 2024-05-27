import SwiftUI

struct CalcPositionInfoView: View {
	@Binding var isPresented: Bool
	var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 10) {
				HStack {
					Text("Description:")
				}
				.font(.headline)
				Text(
"""
 This demo showcases the functionality of paddings and the camera.calcPosition method. Essentially, it allows you to define safe zones on the map where the UI elements of your application can be positioned. Upon selecting an object, a settings menu is prompted, offering three different methods for calculating the camera's position. These settings include adjusting paddings, as well as setting the tilt and bearing angles of the camera.

 A rectangle with red outlines and a small circle in the center is drawn over the map to visualize the current padding settings. After applying these settings, the camera automatically moves to the calculated position, providing a dynamic way to navigate and showcase specific areas or points of interest on the map. This interactive approach demonstrates the flexibility and precision in controlling the camera's viewpoint, enhancing the user's experience by focusing on selected objects with customized viewing parameters.
"""
				)
			}
			.padding()
		}
	}
}
