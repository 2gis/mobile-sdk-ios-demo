import SwiftUI

struct SnapshotView: View {
	var snapshot: UIImage
	var pointA: String
	var pointB: String

	var body: some View {
		VStack(alignment: .leading, spacing: 0) {
			Image(uiImage: self.snapshot)
			.resizable()
			.aspectRatio(contentMode: .fill)
			.cornerRadius(20, corners: [.topLeft, .topRight])
			.clipped()
			HStack{
				Image(systemName: "a.circle.fill")
				Text(self.pointA)
			}
			.padding(10)
			HStack{
				Image(systemName: "b.circle.fill")
				Text(self.pointB)
			}
			.padding(10)
		}
		.background(RoundedRectangle(cornerRadius: 20)
		.fill(Color(UIColor.secondarySystemBackground))
		.shadow(radius: 5)
		)
	}
}

private extension View {
	func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
		clipShape(
			RoundedCorner(
				radius: radius,
				corners: corners
			)
		)
	}
}

private struct RoundedCorner: Shape {
	var radius: CGFloat
	var corners: UIRectCorner

	func path(in rect: CGRect) -> Path {
		let path = UIBezierPath(
			roundedRect: rect,
			byRoundingCorners: corners,
			cornerRadii: CGSize(width: radius, height: radius)
		)
		return Path(path.cgPath)
	}
}
