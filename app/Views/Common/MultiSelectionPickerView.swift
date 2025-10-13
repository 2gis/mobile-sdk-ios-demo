import SwiftUI

struct MultiSelectionPickerView<T: PickerViewOption>: View {
	@Binding private var selection: [T]
	private let options: [T]

	init(selection: Binding<[T]>, options: [T]) {
		self.options = options
		self._selection = selection
	}

	var body: some View {
		VStack(alignment: .leading) {
			HStack {
				if self.selection.count == self.options.count {
					Button("Clear All") {
						self.selection.removeAll()
					}
				} else {
					Button("Choose All") {
						self.selection = self.options
					}
				}
			}
			ForEach(self.options) { option in
				HStack {
					Text(option.name)
						.fixedSize(horizontal: false, vertical: true)
					Spacer()
					if self.selection.contains(option) {
						Image(systemName: "checkmark.circle")
							.resizable()
							.frame(width: 20, height: 20)
							.foregroundColor(.blue)
					} else {
						Image(systemName: "circle")
							.resizable()
							.frame(width: 20, height: 20)
							.foregroundColor(.blue)
					}
				}
				.contentShape(Rectangle())
				.frame(height: 30)
				.onTapGesture {
					if let index = self.selection.firstIndex(of: option) {
						self.selection.remove(at: index)
					} else {
						self.selection.append(option)
					}
				}
			}
		}
	}
}
