import SwiftUI

struct NavigatorBetterRouteSettingsView: View {
	@Binding var settings: NavigatorBetterRouteSettings
	@Binding var isPresented: Bool

	var body: some View {
		NavigationView {
			ScrollView {
				VStack(alignment: .leading) {
					SettingsFormTextFieldView(
						title: "Minimum time gain for an alternative route, seconds",
						value: self.$settings.betterRouteTimeCostThreshold
					)
					SettingsFormTextFieldView(
						title: "Minimum length gain for an alternative route, meters",
						value: self.$settings.betterRouteLengthThreshold
					)
					SettingsFormTextFieldView(
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
