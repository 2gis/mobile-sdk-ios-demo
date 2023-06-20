import SwiftUI

struct SearchDemoView: View {
	@Environment(\.presentationMode) private var presentationMode

	@ObservedObject private var viewModel: SearchDemoViewModel
	private let viewFactory: DemoPageComponentsFactory

	init(
		viewModel: SearchDemoViewModel,
		viewFactory: DemoPageComponentsFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	var body: some View {
		ZStack {
			self.viewFactory.makeMapView()
			if self.viewModel.showCloseMenu {
				self.closeMenu
			}
		}
		.navigationBarItems(
			leading: self.backButton,
			trailing: HStack {
				Button {
					self.viewModel.restoreState()
				} label: {
					Image(systemName: "arrow.triangle.2.circlepath.circle.fill")
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(minWidth: 32, minHeight: 32)
				}
				self.navigationBarTrailingItem()
			}
		)
		.edgesIgnoringSafeArea(.all)
		.navigationBarBackButtonHidden(true)
	}

	private func navigationBarTrailingItem() -> some View {
		NavigationLink(destination: self.viewFactory.makeSearchView(searchStore: self.viewModel.searchStore)) {
			Image(systemName: "magnifyingglass.circle.fill")
			.resizable()
			.frame(minWidth: 32, minHeight: 32)
		}
	}

	private var backButton : some View {
		Button(action: {
			self.viewModel.showCloseMenu = true
		}) {
			HStack {
				Image(systemName: "arrow.left.circle")
				Text("Back")
			}
		}
	}

	private var closeMenu : some View {
		VStack {
			Text("Save search parameters?")
			.foregroundColor(.primaryTitle)
			.fontWeight(.bold)
			.padding([.leading, .trailing, .top], 20)

			HStack(spacing: 30) {
				Button("Save and exit") {
					self.viewModel.saveState()
					self.presentationMode.wrappedValue.dismiss()
				}
				Button("Exit") {
					self.presentationMode.wrappedValue.dismiss()
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
}
