import SwiftUI

struct RouteSearchSettingsDatePicker: View {
	let title: String
	let subtitle: String
	@Binding var date: Date?

	@State private var isPickerShown: Bool = false
	private let dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .short
		return dateFormatter
	}()

	var body: some View {
		VStack(alignment: .leading) {
			Text(self.title)
			.fontWeight(.bold)
			.foregroundColor(.primaryTitle)
			.fixedSize(horizontal: false, vertical: true)
			Text(self.subtitle)
			.fontWeight(.light)
			.foregroundColor(.primaryTitle)
			.fixedSize(horizontal: false, vertical: true)
			HStack {
				Image(systemName: "clock")
				Text(self.date.map { self.dateFormatter.string(from: $0)} ?? "Выбрать время")
				.foregroundColor(.blue)
				.frame(height: 40)
				.onTapGesture {
					self.isPickerShown.toggle()
				}
				Spacer()
				if self.date != nil {
					Image(systemName: "clear")
					.frame(width: 30, height: 30)
					.foregroundColor(.red)
					.onTapGesture {
						self.date = nil
						self.isPickerShown = false
					}
				}
			}
			if self.isPickerShown {
				DatePicker(
					"",
					selection: Binding<Date>(get: {
						if let date = self.date {
							return date
						} else {
							return Date()
						}
					}, set: { date in
						self.date = date
					}),
					displayedComponents: [.date, .hourAndMinute]
				)
			}
		}
	}
}
