import SwiftUI
import DGis

struct SettingsFormTextFieldView<Value>: View {
	typealias RawToValueConverter = (String) -> Value
	typealias ValueToRawConverter = (Value) -> String?
	typealias ValueValidator = (Value) -> Bool
	typealias State = SwiftUI.State

	let title: String
	private let rawToValueConverter: RawToValueConverter
	private let valueValidator: ValueValidator?
	private let keyboardType: UIKeyboardType
	@Binding private var value: Value
	@State private var rawValue: String
	@State private var isValid: Bool = true

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

extension SettingsFormTextFieldView where Value == UInt32 {
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

extension SettingsFormTextFieldView where Value == UInt32? {
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

extension SettingsFormTextFieldView where Value == Int32 {
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

extension SettingsFormTextFieldView where Value == TimeInterval {
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

extension SettingsFormTextFieldView where Value == Float {
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

class SettingsFormTextFieldUIView<Value>: UIView, UITextFieldDelegate {

	typealias RawToValueConverter = (String) -> Value?
	typealias ValueToRawConverter = (Value) -> String?
	typealias ValueValidator = (Value) -> Bool

	private let titleLabel = UILabel()
	private let textField = UITextField()
	private let stackView = UIStackView()

	private let rawToValueConverter: RawToValueConverter
	private let valueToRawConverter: ValueToRawConverter
	private let valueValidator: ValueValidator?

	private var value: Value? {
		didSet {
			onValueChanged?(value)
		}
	}

	var onValueChanged: ((Value?) -> Void)?

	init(
		title: String,
		initialValue: Value?,
		rawToValueConverter: @escaping RawToValueConverter,
		valueToRawConverter: @escaping ValueToRawConverter,
		valueValidator: ValueValidator? = nil,
		keyboardType: UIKeyboardType = .default,
		onValueChanged: @escaping ((Value?) -> Void)
	) {
		self.rawToValueConverter = rawToValueConverter
		self.valueToRawConverter = valueToRawConverter
		self.valueValidator = valueValidator
		self.value = initialValue
		self.onValueChanged = onValueChanged
		super.init(frame: .zero)
		setupViews()
		configure(title: title, keyboardType: keyboardType)
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	private func setupViews() {
		stackView.axis = .vertical
		stackView.spacing = 8
		stackView.translatesAutoresizingMaskIntoConstraints = false

		titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
		titleLabel.numberOfLines = 0
		titleLabel.lineBreakMode = .byWordWrapping

		textField.borderStyle = .roundedRect
		textField.delegate = self
		textField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)

		let clearButton = UIButton(type: .system)
		let config = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular)
		clearButton.setImage(UIImage(systemName: "multiply.circle.fill", withConfiguration: config), for: .normal)
		clearButton.tintColor = .secondaryLabel
		clearButton.addTarget(self, action: #selector(clearTextField), for: .touchUpInside)
		clearButton.setContentHuggingPriority(.required, for: .horizontal)

		let textFieldContainer = UIStackView(arrangedSubviews: [textField, clearButton])
		textFieldContainer.axis = .horizontal
		textFieldContainer.spacing = 8
		textFieldContainer.alignment = .center

		stackView.addArrangedSubview(titleLabel)
		stackView.addArrangedSubview(textFieldContainer)
		addSubview(stackView)

		NSLayoutConstraint.activate([
			stackView.topAnchor.constraint(equalTo: self.topAnchor),
			stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
			stackView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
			stackView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
		])
	}

	private func configure(title: String, keyboardType: UIKeyboardType) {
		titleLabel.text = title
		textField.keyboardType = keyboardType
		if let value = value {
			textField.text = valueToRawConverter(value)
		} else {
			textField.text = ""
		}
	}

	@objc private func textChanged(_ sender: UITextField) {
		let text = sender.text ?? ""
		let convertedValue = rawToValueConverter(text)
		self.value = convertedValue
		updateValidation()
	}

	@objc private func clearTextField() {
		textField.text = ""
		textChanged(textField)
	}

	private func updateValidation() {
		guard let value = self.value else {
			textField.layer.borderWidth = 2
			textField.layer.borderColor = UIColor.red.cgColor
			return
		}

		if let validator = valueValidator, !validator(value) {
			textField.layer.borderWidth = 2
			textField.layer.borderColor = UIColor.red.cgColor
		} else {
			textField.layer.borderWidth = 0
			textField.layer.borderColor = UIColor.clear.cgColor
		}
	}
}
