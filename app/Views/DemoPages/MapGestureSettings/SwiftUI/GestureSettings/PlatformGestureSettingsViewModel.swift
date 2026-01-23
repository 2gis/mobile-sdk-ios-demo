import Combine
import DGis
import SwiftUI

@MainActor
final class PlatformGestureSettingsViewModel: ObservableObject {
	@Published var doubleTapGestureRecognizerEnabled: Bool = true
	@Published var panGestureRecognizerEnabled: Bool = true
	@Published var twoFingerPanGestureRecognizerEnabled: Bool = true
	@Published var rotationGestureRecognizerEnabled: Bool = true
	@Published var pinchGestureRecognizerEnabled: Bool = true
	@Published var twoFingerTapGestureRecognizerEnabled: Bool = true
	@Published var doubleTapAndPanGestureRecognizerEnabled: Bool = true

	@Published var doubleTapScalingCenter: MapGestureViewOptions.ScalingCenter
	@Published var twoFingerTapScalingCenter: MapGestureViewOptions.ScalingCenter
	@Published var pinchScalingCenter: MapGestureViewOptions.ScalingCenter

	private let mapGestureUIView: IMapGestureUIView?
	@Binding var mapGestureViewOptions: MapGestureViewOptions

	init(
		mapGestureUIView: IMapGestureUIView?,
		mapGestureViewOptions: Binding<MapGestureViewOptions>
	) {
		self.mapGestureUIView = mapGestureUIView
		self._mapGestureViewOptions = mapGestureViewOptions
		self.doubleTapGestureRecognizerEnabled = self.mapGestureUIView?.doubleTapAndPanGestureRecognizer?.isEnabled ?? true
		self.panGestureRecognizerEnabled = self.mapGestureUIView?.panGestureRecognizer?.isEnabled ?? true
		self.twoFingerPanGestureRecognizerEnabled = self.mapGestureUIView?.twoFingerPanGestureRecognizer?.isEnabled ?? true
		self.rotationGestureRecognizerEnabled = self.mapGestureUIView?.rotationGestureRecognizer?.isEnabled ?? true
		self.pinchGestureRecognizerEnabled = self.mapGestureUIView?.pinchGestureRecognizer?.isEnabled ?? true
		self.twoFingerTapGestureRecognizerEnabled = self.mapGestureUIView?.twoFingerPanGestureRecognizer?.isEnabled ?? true
		self.doubleTapAndPanGestureRecognizerEnabled = self.mapGestureUIView?.doubleTapAndPanGestureRecognizer?.isEnabled ?? true
		self.doubleTapScalingCenter = mapGestureViewOptions.doubleTapScalingCenter.wrappedValue
		self.twoFingerTapScalingCenter = mapGestureViewOptions.twoFingerTapScalingCenter.wrappedValue
		self.pinchScalingCenter = mapGestureViewOptions.pinchScalingCenter.wrappedValue
	}

	func set() {
		self.mapGestureUIView?.doubleTapAndPanGestureRecognizer?.isEnabled = self.doubleTapGestureRecognizerEnabled
		self.mapGestureUIView?.panGestureRecognizer?.isEnabled = self.panGestureRecognizerEnabled
		self.mapGestureUIView?.twoFingerPanGestureRecognizer?.isEnabled = self.twoFingerPanGestureRecognizerEnabled
		self.mapGestureUIView?.rotationGestureRecognizer?.isEnabled = self.rotationGestureRecognizerEnabled
		self.mapGestureUIView?.pinchGestureRecognizer?.isEnabled = self.pinchGestureRecognizerEnabled
		self.mapGestureUIView?.twoFingerPanGestureRecognizer?.isEnabled = self.twoFingerTapGestureRecognizerEnabled
		self.mapGestureUIView?.doubleTapAndPanGestureRecognizer?.isEnabled = self.doubleTapAndPanGestureRecognizerEnabled
		self.mapGestureViewOptions = .init(
			doubleTapScalingCenter: self.doubleTapScalingCenter,
			twoFingerTapScalingCenter: self.twoFingerTapScalingCenter,
			pinchScalingCenter: self.pinchScalingCenter
		)
	}
}
