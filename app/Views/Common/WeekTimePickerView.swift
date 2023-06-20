import SwiftUI
import DGis

struct WeekTimePickerView: View {
	@Binding private var weekTime: WeekTime
	@SwiftUI.State private var isWeekDayPopoverShown: Bool = false
	@SwiftUI.State private var isDayTimePopoverShown: Bool = false

	init(weekTime: Binding<WeekTime>) {
		self._weekTime = weekTime
	}

	var body: some View {
		HStack {
			Button("\(self.weekTime.weekDay.name)") {
				self.isWeekDayPopoverShown = true
			}
			.font(.headline)
			.sheet(isPresented: self.$isWeekDayPopoverShown) {
				PickerView(
					title: nil,
					selection: self.$weekTime.weekDay,
					options: WeekDay.availableValues,
					pickerStyle: .wheel
				)
				.modifier(EmbedInNavigationView(title: "Week day", isPresented: self.$isWeekDayPopoverShown))
			}
			.padding(.trailing, 10)
			Button("\(self.weekTime.time.hours) : \(self.weekTime.time.minutes)") {
				self.isDayTimePopoverShown = true
			}
			.font(.headline)
			.sheet(isPresented: self.$isDayTimePopoverShown) {
				DatePicker(
					"",
					selection: Binding<Date>(get: {
						Date.from(weekTime: self.weekTime)
					}, set: { date in
						self.weekTime.time = date.weekTime.time
					}),
					displayedComponents: [.hourAndMinute]
				)
				.datePickerStyle(.wheel)
				.modifier(EmbedInNavigationView(title: "Time", isPresented: self.$isDayTimePopoverShown))
			}
		}
	}
}

private struct EmbedInNavigationView: ViewModifier {
	let title: String
	@Binding var isPresented: Bool

	func body(content: Content) -> some View {
		NavigationView {
			content
			.navigationBarTitle(self.title)
			.navigationBarItems(leading: Button("Close", action: {
				self.isPresented = false
			}))
		}
	}
}

extension Date {
	var weekTime: WeekTime {
		let calendar = Calendar.current
		let components = calendar.dateComponents([.weekday, .hour, .minute], from: self)
		let weekDay: WeekDay = components.weekday.flatMap { WeekDay(rawValue: UInt32($0 - 1) )} ?? .monday
		let hours = UInt8(components.hour ?? 0)
		let minutes = UInt8(components.minute ?? 0)
		return WeekTime(
			weekDay: weekDay,
			time: DayTime(hours: hours, minutes: minutes)
		)
	}

	var dayTime: DayTime {
		let calendar = Calendar.current
		let components = calendar.dateComponents([.hour, .minute], from: self)
		let hours = UInt8(components.hour ?? 0)
		let minutes = UInt8(components.minute ?? 0)
		return DayTime(hours: hours, minutes: minutes)
	}

	static func from(weekTime: WeekTime) -> Date {
		let calendar = Calendar.current
		var components = calendar.dateComponents([.weekday, .hour, .minute], from: Date())
		components.weekday = Int(weekTime.weekDay.rawValue + 1)
		components.hour = Int(weekTime.time.hours)
		components.minute = Int(weekTime.time.minutes)
		return calendar.date(from: components) ?? Date()
	}
}

extension WeekDay: PickerViewOption {
	public var id: WeekDay { self }

	var name: String {
		switch self {
			case .monday:
				return "Monday"
			case .tuesday:
				return "Tuesday"
			case .wednesday:
				return "Wednesday"
			case .thursday:
				return "Thursday"
			case .friday:
				return "Friday"
			case .saturday:
				return "Saturday"
			case .sunday:
				return "Sunday"
			@unknown default:
				assertionFailure("Unsupported WeekDay \(self)")
				return "Unsupported week day \(self.rawValue)"
		}
	}
	static let availableValues: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
}
