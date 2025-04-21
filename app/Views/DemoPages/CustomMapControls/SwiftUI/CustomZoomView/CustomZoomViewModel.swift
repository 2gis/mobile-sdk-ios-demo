import DGis
import SwiftUI

public final class CustomZoomViewModel: ObservableObject {
	@Published var zoomInHighlighted: Bool = false {
		didSet {
			self.zoomInHighlighted ? self.onStartZoom(button: .zoomIn) : self.onStopZoom(button: .zoomIn)
		}
	}

	@Published var zoomOutHighlighted: Bool = false {
		didSet {
			self.zoomOutHighlighted ? self.onStartZoom(button: .zoomOut) : self.onStopZoom(button: .zoomOut)
		}
	}

	@Published var zoomInEnabled: Bool = false
	@Published var zoomOutEnabled: Bool = false

	private let model: ZoomControlModel
	private var zoomInEnabledCancellable: ICancellable = NoopCancellable()
	private var zoomOutEnabledCancellable: ICancellable = NoopCancellable()

	init(map: Map) {
		self.model = ZoomControlModel(map: map)

		self.zoomInEnabledCancellable = self.model.isEnabled(button: .zoomIn).sinkOnMainThread { [weak self] isEnabled in
			guard let self = self else { return }
			self.zoomInEnabled = isEnabled
		}
		self.zoomOutEnabledCancellable = self.model.isEnabled(button: .zoomOut).sinkOnMainThread { [weak self] isEnabled in
			guard let self = self else { return }
			self.zoomOutEnabled = isEnabled
		}
	}

	public func onStartZoom(button: ZoomControlButton) {
		guard self.model.isEnabled(button: button).value else {
			return
		}
		self.model.setPressed(button: button, value: true)
	}

	public func onStopZoom(button: ZoomControlButton) {
		guard self.model.isEnabled(button: button).value else {
			return
		}
		self.model.setPressed(button: button, value: false)
	}
}
