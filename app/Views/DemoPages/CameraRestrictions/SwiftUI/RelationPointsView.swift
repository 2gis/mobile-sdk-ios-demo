import SwiftUI

struct RelationPointsView: View {
	@Binding var relationPoints: [RelationPoint]
	let sectionName: String
	let textFieldFrameWidth: CGFloat
	@State private var editingField: UUID?

	var body: some View {
		Section(header: Text(self.sectionName)) {
			ForEach(self.$relationPoints) { point in
				HStack {
					Text("Zoom: ")
					TextField("Zoom", value: point.zoom, formatter: .zoomFormatter)
						.id(point.id)
						.keyboardType(.numbersAndPunctuation)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.frame(width: self.textFieldFrameWidth)
						.disabled(self.editingField != point.id)
					Spacer()
					Text("Tilt: ")
					TextField("Tilt", value: point.tilt, formatter: .tiltFormatter)
						.id(point.id)
						.keyboardType(.numbersAndPunctuation)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.frame(width: self.textFieldFrameWidth)
						.disabled(self.editingField != point.id)
					if self.editingField == point.id {
						Button(action: {
							self.editingField = nil
						}) {
							Image(systemName: "checkmark.circle")
								.foregroundColor(.green)
								.font(.title2)
						}
						.transition(.scale)
					}
				}
				.swipeActions(edge: .trailing, allowsFullSwipe: true) {
					if self.editingField != point.id {
						Button {
							guard let index = relationPoints.firstIndex(where: { $0.id == point.id }) else { return }
							self.relationPoints.remove(at: index)
						} label: {
							Label("Delete", systemImage: "trash.fill")
						}
						.tint(.red)
					}
				}
				.swipeActions(edge: .leading, allowsFullSwipe: true) {
					if self.editingField != point.id {
						Button {
							self.editingField = point.id
						} label: {
							Label("Edit", systemImage: "pencil")
						}
						.tint(.yellow)
					}
				}
			}
			Button(action: {
				DispatchQueue.main.async {
					self.relationPoints.append(.init(zoom: 0.0, tilt: 0.0))
				}
			}, label: {
				HStack {
					Image(systemName: "plus.circle.fill")
						.foregroundColor(.accentColor)
					Text("Add relation point")
				}
			})
		}
	}
}
