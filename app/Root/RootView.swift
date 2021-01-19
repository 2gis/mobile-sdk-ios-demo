import SwiftUI
import PlatformSDK

struct RootView: View {
	private let viewModel: RootViewModel
	private let viewFactory: RootViewFactory

	init(
		viewModel: RootViewModel,
		viewFactory: RootViewFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		NavigationView  {
			ZStack(alignment: .bottomTrailing) {
				self.viewFactory.makeMapView()
				self.settingsButton()
			}
			.navigationBarItems(
				leading: self.navigationBarLeadingItem()
			)
			.navigationBarTitle("2GIS", displayMode: .inline)
			.edgesIgnoringSafeArea(.all)
		}.navigationViewStyle(StackNavigationViewStyle())
	}

	private func navigationBarLeadingItem() -> some View {
		NavigationLink(destination: self.viewFactory.makeSearchView()) {
			Image(systemName: "magnifyingglass.circle.fill")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(minWidth: 32, minHeight: 32)
		}
	}

	@State private var showActionSheet = false
	private func settingsButton() -> some View {
		Button(action: {
			self.showActionSheet = true
		}, label: {
			Image(systemName: "list.bullet")
				.frame(width: 40, height: 40, alignment: .center)
				.contentShape(Rectangle())
				.background(
					Circle().fill(Color.white)
				)
		})
		.padding([.bottom, .trailing], 40.0)
		.actionSheet(isPresented: $showActionSheet) {
			ActionSheet(
				title: Text("Тестовые кейсы"),
				message: Text("Выберите необходимый"),
				buttons: [
					.default(Text("Тест перелетов по Москве")) {
						self.viewModel.testCamera()
					},
					.default(Text("Перелет в текущую геопозицию")) {
						self.viewModel.showCurrentPosition()
					},
					.default(Text("Тест добавления маркеров")) {
						// TODO
					},
					.cancel(Text("Отмена"))
				])
		}

	}
}
