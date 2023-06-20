import SwiftUI
import DGis

struct RootView: View {
	@EnvironmentObject private var navigationService: NavigationService
	@ObservedObject private var viewModel: RootViewModel
	private let viewFactory: RootViewFactory

	init(
		viewModel: RootViewModel,
		viewFactory: RootViewFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		List(self.viewModel.demoPages) { page in
			DemoPageListRow(page: page, action: {
				do {
					try self.navigationService.push(self.destinationView(for: page), animated: true)
				} catch let error as DGis.SDKError {
					self.viewModel.errorMessage = error.description
				} catch {
					self.viewModel.errorMessage = "Unknown error: \(error)"
				}
			})
		}
		.navigationBarItems(trailing: self.settingsButton())
		.navigationBarTitle("2GIS MobileSDK Examples", displayMode: .inline)
		.navigationBarHidden(false)
		.sheet(isPresented: self.$viewModel.showsSettings) {
			SettingsView(
				viewModel: self.viewModel.settingsViewModel,
				show: self.$viewModel.showsSettings
			)
		}
		.alert(isPresented: self.$viewModel.isErrorAlertShown) {
			Alert(title: Text(self.viewModel.errorMessage ?? ""))
		}
	}

	private func destinationView(for page: DemoPage) throws -> some View {
		try self.viewFactory.makeDemoPageView(page)
			.navigationBarTitle(page.name)
			.environmentObject(self.navigationService)
	}

	private func settingsButton() -> some View {
		Button {
			self.viewModel.showsSettings = true
		} label: {
			Image(systemName: "gear")
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: 30)
		}
	}
}
