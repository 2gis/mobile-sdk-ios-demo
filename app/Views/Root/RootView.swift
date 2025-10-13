import DGis
import SwiftUI

struct RootView: View {
	typealias State = SwiftUI.State
	@ObservedObject var viewModel: RootViewModel
	@State private var selectedTab: DemoCategory = .map
	@State private var selectedFramework: DemoFramework = .swiftUI
	let swiftUIFactory: SwiftUIDemoFactory
	let uiKitFactory: UIKitDemoFactory

	private var filteredCategories: [DemoCategory] {
		DemoCategory.allCases.filter { category in
			!self.viewModel.demos(for: category).filter { demo in
				demo.framework.contains(self.selectedFramework)
			}.isEmpty
		}
	}

	var body: some View {
		NavigationView {
			VStack {
				if self.viewModel.isFiltering {
					TextField("Filter", text: self.$viewModel.filterText)
						.textFieldStyle(RoundedBorderTextFieldStyle())
						.padding(.horizontal, 15)
						.frame(height: 25)
				} else {
					Picker("Framework", selection: self.$selectedFramework) {
						ForEach(DemoFramework.allCases) { framework in
							Text(framework.displayName).tag(framework)
						}
					}
					.pickerStyle(.segmented)
					.padding(.horizontal, 15)
					.frame(height: 25)
				}
				TabView(selection: self.$selectedTab) {
					ForEach(self.filteredCategories, id: \.self) { category in
						DemoListView(
							viewModel: self.viewModel,
							framework: self.$selectedFramework,
							swiftUIFactory: self.swiftUIFactory,
							uiKitFactory: self.uiKitFactory,
							title: category.displayName,
							category: category
						)
						.tabItem {
							self.makeTabLabel(category: category)
						}
						.tag(category)
					}
				}
				.ignoresSafeArea(.keyboard, edges: .bottom)
				.sheet(isPresented: self.$viewModel.showsSettings) {
					SettingsView(
						viewModel: self.viewModel.settingsViewModel,
						show: self.$viewModel.showsSettings
					)
				}
				.alert(isPresented: self.$viewModel.isErrorAlertShown) {
					Alert(title: Text(self.viewModel.errorMessage ?? ""))
				}
				.onChange(of: self.viewModel.filterText) { _ in
					self.viewModel.filterDemos()
				}
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
		.navigationBarHidden(false)
		.navigationTitle("TestApp")
		.navigationBarItems(
			leading: self.makefilterButton(),
			trailing: self.makeSettingsButton()
		)
	}

	private func makefilterButton() -> some View {
		let filterIcon = "line.horizontal.3.decrease.circle"
		let closeIcon = "xmark.circle.fill"
		return Button(action: {
			if self.viewModel.isFiltering {
				self.viewModel.filterText = ""
				self.viewModel.isFiltering = false
				self.viewModel.filterDemos()
			} else {
				self.viewModel.isFiltering = true
			}
		}) {
			Image(systemName: self.viewModel.isFiltering ? closeIcon : filterIcon)
				.resizable()
				.frame(width: 24, height: 24)
				.foregroundColor(self.viewModel.isFiltering ? .gray : .accentColor)
		}
	}

	private func makeSettingsButton() -> some View {
		Button(action: {
			self.viewModel.showsSettings = true
		}) {
			Image(systemName: "gearshape.fill")
				.resizable()
				.frame(width: 24, height: 24)
		}
	}

	private func makeTabLabel(category: DemoCategory) -> some View {
		let demoPageCount: Int = self.viewModel.demos(for: category).count(where: { $0.framework.contains(self.selectedFramework) })
		let title = "\(category.displayName) " + "(\(demoPageCount))"
		return Label(title, systemImage: category.iconName)
	}
}

struct DemoListView: View {
	@EnvironmentObject private var navigationService: NavigationService
	@ObservedObject var viewModel: RootViewModel
	@Binding var framework: DemoFramework

	let swiftUIFactory: SwiftUIDemoFactory
	let uiKitFactory: UIKitDemoFactory
	let title: String
	let category: DemoCategory

	var body: some View {
		List(self.viewModel.demos(for: self.category).filter { $0.framework.contains(self.framework) }.sorted { $0.name < $1.name }) { demo in
			Button(action: {
				do {
					switch self.framework {
					case .swiftUI:
						try self.navigationService.push(self.destinationView(for: demo), animated: true)
					case .uiKit:
						try self.navigationService.push(self.destinationUIViewController(for: demo), animated: true)
					@unknown default:
						assertionFailure("Unknown type: \(self)")
					}
				} catch let error as DGis.SDKError {
					self.viewModel.errorMessage = error.description
				} catch {
					self.viewModel.errorMessage = "Failed to create demo example: \(error)"
				}
			}) {
				Text(demo.name)
			}
		}
		.navigationTitle(self.title)
	}

	private func destinationView(for page: DemoPage) throws -> some View {
		try self.swiftUIFactory.makeDemoPageView(page)
			.navigationBarTitle(page.name)
			.environmentObject(self.navigationService)
	}

	private func destinationUIViewController(for page: DemoPage) throws -> UIViewController {
		let controller = try self.uiKitFactory.makeDemoPageUIView(page)
		controller.title = page.name
		return controller
	}
}
