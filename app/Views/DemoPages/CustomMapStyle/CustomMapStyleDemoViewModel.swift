import SwiftUI
import Combine
import PlatformMapSDK

final class CustomMapStyleDemoViewModel: ObservableObject {
	/// Whether a style picker sheet is to be displayed.
	@Published var showsStylePicker: Bool = false
	var stylePickerViewModel: StylePickerViewModel

	private let map: Map
	private var loadStyleCancellable: PlatformMapSDK.Cancellable?

	init(
		styleFactory: @escaping () -> IStyleFactory,
		map: Map
	) {
		self.map = map
		self.stylePickerViewModel = StylePickerViewModel(
			styleFactory: styleFactory,
			map: self.map
		)
	}
}
