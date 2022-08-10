import SwiftUI

struct NavigatorSettingsView: View {
	@ObservedObject private var viewModel: NavigatorSettingsViewModel
	private let startNavigationCallback: () -> Void
	private let restoreNavigationCallback: () -> Void
	private let cancelCallback: () -> Void

	init(
		viewModel: NavigatorSettingsViewModel,
		startNavigationCallback: @escaping () -> Void,
		restoreNavigationCallback: @escaping () -> Void,
		cancelCallback: @escaping () -> Void
	) {
		self.viewModel = viewModel
		self.startNavigationCallback = startNavigationCallback
		self.restoreNavigationCallback = restoreNavigationCallback
		self.cancelCallback = cancelCallback
	}

	var body: some View {
		VStack {
			Text("Navigation settings:")
			.foregroundColor(.primaryTitle)
			.fontWeight(.bold)
			.padding(.top, 10)

			VStack(alignment: .center) {
				Toggle("Freeroam", isOn: self.$viewModel.isFreeRoam)
				.foregroundColor(.primaryTitle)
				.padding([.leading, .trailing, .top], 10)

				if self.viewModel.isFreeRoam == false {
					Toggle("Simulation", isOn: self.$viewModel.isSimulation)
					.foregroundColor(.primaryTitle)
					.padding([.leading, .trailing], 10)
				}

				if self.viewModel.isSimulation, self.viewModel.isFreeRoam == false {
					self.speedPicker(
						value: self.$viewModel.simulationSpeedKmH,
						in: 0...self.viewModel.maxSimulationSpeedKmH,
						title: "Speed \(Int(self.viewModel.simulationSpeedKmH)) km/h"
					)
				}
				self.speedPicker(
					value: self.$viewModel.allowableSpeedExcessKmH,
					in: 0...self.viewModel.maxAllowableSpeedExcessKmH,
					title: "Permissible speeding \(Int(self.viewModel.allowableSpeedExcessKmH)) km/h"
				)
				self.voiceSettingsButton()
				.padding([.leading, .trailing, .top], 10)
				self.freeRoamSettingsButton()
				.padding([.leading, .trailing, .top], 10)
				PickerView(
					title: "Route type",
					selection: self.$viewModel.routeType,
					options: self.viewModel.routeTypeSources,
					pickerStyle: .segmented
				)
				.padding([.leading, .trailing, .top], 10)
			}
			.padding(.top, 10)

			HStack(spacing: 30) {
				Button("Cancel") {
					self.cancelCallback()
				}

				if self.viewModel.navigationState != nil {
					Button("Restore") {
						self.restoreNavigationCallback()
					}
				}

				Button("Go!") {
					self.startNavigationCallback()
				}
			}
			.frame(height: 44)
			.padding([.bottom, .top], 10)
		}
		.background(Color(.systemBackground))
		.cornerRadius(10)
		.shadow(radius: 3)
		.padding([.leading, .trailing], 20)
	}

	private func speedPicker<V>(
		value: Binding<V>,
		in bounds: ClosedRange<V>,
		title: String
	) -> some View where V : Strideable {
		Stepper(
			value: value,
			in: bounds,
			label: {
				Text(title)
				.foregroundColor(.primaryTitle)
			}
		)
		.foregroundColor(.black)
		.padding([.leading, .trailing], 10)
	}

	private func voiceSettingsButton() -> some View {
		let title: String
		var voiceInfo: String?
		if let voice = self.viewModel.currentVoice {
			title = "Voice"
			voiceInfo = "\(voice.info.name)(\(voice.language))"
		} else {
			title = "Choose navigator voice"
		}
		return SettingsFormDisclosureButton(title: title, subtitle: voiceInfo) {
			self.viewModel.showNavigatorVoicesSettings = true
		}
		.sheet(isPresented: self.$viewModel.showNavigatorVoicesSettings) {
			NavigatorVoicesSettingsView(
				viewModel: self.viewModel,
				isPresented: self.$viewModel.showNavigatorVoicesSettings
			)
		}
	}

	private func freeRoamSettingsButton() -> some View {
		SettingsFormDisclosureButton(title: "Free Roam settings") {
			self.viewModel.showFreeRoamSettings = true
		}
		.sheet(isPresented: self.$viewModel.showFreeRoamSettings) {
			FreeRoamSettingsView(
				settings: self.$viewModel.freeRoamSettings,
				isPresented: self.$viewModel.showFreeRoamSettings
			)
		}
	}
}
