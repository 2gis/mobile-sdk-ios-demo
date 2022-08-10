import SwiftUI

protocol PickerViewOption: Identifiable, Hashable {
	var name: String { get }
}

struct PickerView<T: PickerViewOption, S: PickerStyle>: View {
	private let title: String?
	private let titleFont: Font
	private let subtitle: String?
	private let options: [T]
	private let pickerStyle: S
	@Binding private var selection: T

	init(title: String?,
		 titleFont: Font = Font.system(size: 20),
		 subtitle: String? = nil,
		 selection: Binding<T>,
		 options: [T],
		 pickerStyle: S
	) {
		self.title = title
		self.titleFont = titleFont
		self.subtitle = subtitle
		self.options = options
		self.pickerStyle = pickerStyle
		self._selection = selection
	}

	var body: some View {
		VStack(alignment: .leading) {
			if let title = self.title {
				Text(title)
				.font(self.titleFont)
				.fontWeight(.bold)
				.foregroundColor(.primaryTitle)
			}
			if let subtitle = self.subtitle {
				Text(subtitle)
				.fontWeight(.ultraLight)
				.foregroundColor(.gray)
			}
			Picker(
				selection: self.$selection,
				label: Text(self.title ?? ""),
				content: {
					ForEach(self.options) { option in
						Text(option.name)
					}
				}
			)
			.pickerStyle(self.pickerStyle)
		}
	}
}
