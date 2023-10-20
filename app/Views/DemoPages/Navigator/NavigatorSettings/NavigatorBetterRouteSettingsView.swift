import SwiftUI

struct NavigatorBetterRouteSettingsView: View {
	@Binding private var isPresented: Bool
	@Binding private var settings: NavigatorBetterRouteSettings

	init(settings: Binding<NavigatorBetterRouteSettings>, isPresented: Binding<Bool>) {
		self._settings = settings
		self._isPresented = isPresented
	}

	var body: some View {
		NavigationView {
			ScrollView {
				VStack(alignment: .leading) {
					SettingsFormTextField(
						title: "Minimum time gain for an alternative route, seconds",
						value: self.$settings.betterRouteTimeCostThreshold
					)
					SettingsFormTextField(
						title: "Minimum length gain for an alternative route, meters",
						value: self.$settings.betterRouteLengthThreshold
					)
					SettingsFormTextField(
						title: "Timeout for alternative route search. Must be at least 5 seconds",
						value: self.$settings.routeSearchDefaultDelay
					)
				}
				.padding()
			}
			.navigationBarTitle(Text("Alternative routes settings"), displayMode: .inline)
			.navigationBarItems(trailing: Button("Close", action: { self.isPresented = false }))
		}
	}
}
