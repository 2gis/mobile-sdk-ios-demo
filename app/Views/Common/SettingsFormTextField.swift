import SwiftUI
import DGis

struct SettingsFormTextField<Value>: View {
	typealias RawToValueConverter = (String) -> Value
	typealias ValueToRawConverter = (Value) -> String?
	typealias ValueValidator = (Value) -> Bool

	let title: String
	private let rawToValueConverter: RawToValueConverter
	private let valueValidator: ValueValidator?
	private let keyboardType: UIKeyboardType
	@Binding private var value: Value
	@SwiftUI.State private var rawValue: String
	@SwiftUI.State private var isValid: Bool = true

	init(
		title: String,
		value: Binding<Value>,
		rawToValueConverter: @escaping RawToValueConverter,
		valueToRawConverter: ValueToRawConverter,
		valueValidator: ValueValidator? = nil,
		keyboardType: UIKeyboardType
	) {
		self.title = title
		self._value = value
		self._rawValue = State(initialValue: valueToRawConverter(value.wrappedValue) ?? "")
		self.rawToValueConverter = rawToValueConverter
		self.valueValidator = valueValidator
		self.keyboardType = keyboardType
	}

	var body: some View {
		let binding = Binding<String>(
			get: {
				self.rawValue
			},
			set: {
				self.rawValue = $0
				let resultValue = self.rawToValueConverter($0)
				self.value = resultValue
				if let valueValidator = self.valueValidator {
					let isValueValid = valueValidator(resultValue)
					self.isValid = isValueValid || $0.isEmpty && !isValueValid
				}
			}
		)
		Text(self.title)
		.fontWeight(.bold)
		.foregroundColor(.primary)
		.fixedSize(horizontal: false, vertical: true)
		TextField(self.title, text: binding)
		.textFieldStyle(.roundedBorder)
		.border(Color.red, width: self.isValid ? 0 : 2)
		.keyboardType(self.keyboardType)
		.modifier(TextFieldClearButton(text: binding))
	}
}

extension SettingsFormTextField where Value == UInt32 {
	init(
		title: String,
		value: Binding<UInt32>
	) {
		self.init(
			title: title,
			value: value,
			rawToValueConverter: { UInt32($0) ?? 0 },
			valueToRawConverter: { $0.description },
			keyboardType: .numberPad
		)
	}
}

extension SettingsFormTextField where Value == UInt32? {
	init(
		title: String,
		value: Binding<UInt32?>
	) {
		self.init(
			title: title,
			value: value,
			rawToValueConverter: { UInt32($0) },
			valueToRawConverter: { $0.map {"\($0)"} },
			valueValidator: { $0 != nil },
			keyboardType: .numberPad
		)
	}
}

extension SettingsFormTextField where Value == Int32 {
	init(
		title: String,
		value: Binding<Int32>
	) {
		self.init(
			title: title,
			value: value,
			rawToValueConverter: { Int32($0) ?? 0 },
			valueToRawConverter: { $0.description },
			keyboardType: .numberPad
		)
	}
}

extension SettingsFormTextField where Value == TimeInterval {
	init(
		title: String,
		value: Binding<TimeInterval>
	) {
		self.init(
			title: title,
			value: value,
			rawToValueConverter: { TimeInterval($0) ?? 0 },
			valueToRawConverter: { "\($0)" },
			keyboardType: .numbersAndPunctuation
		)
	}
}

extension SettingsFormTextField where Value == Float {
	init(
		title: String,
		value: Binding<Float>
	) {
		self.init(
			title: title,
			value: value,
			rawToValueConverter: { Float($0) ?? 0.0 },
			valueToRawConverter: { "\($0)" },
			keyboardType: .numbersAndPunctuation
		)
	}
}
