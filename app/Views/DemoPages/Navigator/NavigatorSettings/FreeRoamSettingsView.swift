import SwiftUI

struct FreeRoamSettingsView: View {
	@Binding private var isPresented: Bool
	@Binding private var settings: FreeRoamSettings

	init(settings: Binding<FreeRoamSettings>, isPresented: Binding<Bool>) {
		self._settings = settings
		self._isPresented = isPresented
	}

	var body: some View {
		NavigationView {
			ScrollView {
				VStack {
					SettingsFormTextField(
						title: "Cache distance on route, m",
						value: self.$settings.cacheDistanceOnRoute
					)
					SettingsFormTextField(
						title: "Cache radius on route, m",
						value: self.$settings.cacheRadiusOnRoute
					)
					SettingsFormTextField(
						title: "Cache radius in free roam, m",
						value: self.$settings.cacheRadiusInFreeRoam
					)
				}
				.padding()
			}
			.navigationBarTitle(Text("Free Roam settings"), displayMode: .inline)
			.navigationBarItems(trailing: Button("Close", action: { self.isPresented = false }))
		}
	}
}
