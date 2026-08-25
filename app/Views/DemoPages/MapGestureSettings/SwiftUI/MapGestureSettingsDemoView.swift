import DGis
import SwiftUI

struct MapGestureSettingsDemoView: View {
	typealias State = SwiftUI.State

	@ObservedObject private var viewModel: MapGestureSettingsDemoViewModel
	@State private var showCommonGestureSettings = false
	@State private var showMultiTouchSettings = false
	@State private var showRotationSettings = false
	@State private var showScalingSettings = false
	@State private var showTiltSettings = false
	@State private var showPlatformGestureSettings = false

	private let mapFactory: IMapFactory

	init(
		viewModel: MapGestureSettingsDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack {
			ZStack(alignment: .bottomTrailing) {
				self.mapFactory.mapView
					.showsAPIVersion(true)
					.copyrightAlignment(.bottomLeft)
					.gestureView(self.viewModel.mapGestureUIView)
					.objectLongPressCallback(callback: .init(
						callback: { [viewModel = self.viewModel] objectInfo in
							Task { @MainActor in
								viewModel.longPress(objectInfo)
							}
						}
					))
				VStack(spacing: 12.0) {
					if !self.viewModel.showSettings {
						self.settingsButton()
							.frame(width: 100, height: 100, alignment: .bottomTrailing)
					}
					if self.viewModel.showSettings {
						if self.viewModel.mapGestureType == .mapRecognizer {
							if let gestureManager = self.mapFactory.gestureManager {
								self.makeMapRecognizerSettingsView(gestureManager: gestureManager)
							}
						}
						self.makePlatformRecognizerView()
						DetailsActionView(
							action: {
								self.viewModel.nextMapGestureType()
							},
							primaryText: self.viewModel.mapGestureType.text,
							detailsText: "Choose gesture type"
						)
						DetailsActionView(
							action: {
								self.viewModel.showSettings = false
							},
							primaryText: "Close"
						)
					}
				}
				.padding(.bottom, 40)
				.padding(.trailing, 20)
			}
		}
		.edgesIgnoringSafeArea(.all)
	}

	private func makeMapRecognizerSettingsView(gestureManager: GestureManager) -> some View {
		VStack(spacing: 12.0) {
			DetailsActionView(
				action: {
					self.showCommonGestureSettings = true
				},
				primaryText: "CommonGestureSettings"
			)
			.sheet(isPresented: self.$showCommonGestureSettings) {
				CommonGestureSettingsView(
					viewModel: CommonGestureSettingsViewModel(gestureManager: gestureManager),
					isPresented: self.$showCommonGestureSettings
				)
			}

			DetailsActionView(
				action: {
					self.showMultiTouchSettings = true
				},
				primaryText: "MultiTouchSettings"
			)
			.sheet(isPresented: self.$showMultiTouchSettings) {
				MultiTouchGestureSettingsView(
					viewModel: MultiTouchGestureSettingsViewModel(gestureManager: gestureManager),
					isPresented: self.$showMultiTouchSettings
				)
			}

			DetailsActionView(
				action: {
					self.showRotationSettings = true
				},
				primaryText: "RotationSettings"
			)
			.sheet(isPresented: self.$showRotationSettings) {
				RotationGestureSettingsView(
					viewModel: RotationGestureSettingsViewModel(
						gestureManager: gestureManager,
						targetGeoPoint: self.viewModel.targetGeoPoint
					),
					isPresented: self.$showRotationSettings
				)
			}

			DetailsActionView(
				action: {
					self.showScalingSettings = true
				},
				primaryText: "ScalingSettings"
			)
			.sheet(isPresented: self.$showScalingSettings) {
				ScalingGestureSettingsView(
					viewModel: ScalingGestureSettingsViewModel(
						gestureManager: gestureManager,
						targetGeoPoint: self.viewModel.targetGeoPoint
					),
					isPresented: self.$showScalingSettings
				)
			}

			DetailsActionView(
				action: {
					self.showTiltSettings = true
				},
				primaryText: "TiltSettings"
			)
			.sheet(isPresented: self.$showTiltSettings) {
				TiltGestureSettingsView(
					viewModel: TiltGestureSettingsViewModel(
						gestureManager: gestureManager
					),
					isPresented: self.$showTiltSettings
				)
			}
		}
	}

	private func makePlatformRecognizerView() -> some View {
		DetailsActionView(
			action: {
				self.showPlatformGestureSettings = true
			},
			primaryText: "PlatformGestureSettings"
		)
		.sheet(isPresented: self.$showPlatformGestureSettings) {
			PlatformGestureSettingsView(
				viewModel: PlatformGestureSettingsViewModel(
					mapGestureUIView: self.mapFactory.mapView.currentGestureView,
					mapGestureViewOptions: self.$viewModel.mapGestureViewOptions
				),
				isPresented: self.$showPlatformGestureSettings
			)
		}
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "pin.fill") {
			self.viewModel.showSettings = true
		}
	}
}
