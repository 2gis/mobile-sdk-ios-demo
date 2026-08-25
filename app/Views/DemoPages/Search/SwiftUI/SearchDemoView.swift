import DGis
import SwiftUI

struct SearchDemoView: View {
	@Environment(\.presentationMode) private var presentationMode

	@ObservedObject private var viewModel: SearchDemoViewModel
	private let mapFactory: IMapFactory
	private let directoryViewsFactory: IDirectoryViewsFactory

	init(
		viewModel: SearchDemoViewModel,
		mapFactory: IMapFactory,
		directoryViewsFactory: IDirectoryViewsFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.directoryViewsFactory = directoryViewsFactory
	}

	var body: some View {
		ZStack {
			ZStack(alignment: .bottom) {
				self.mapFactory.mapView
					.objectTappedCallback(callback: .init(
						callback: { [viewModel = self.viewModel] objectInfo in
							Task { @MainActor in
								viewModel.getMarkerItemInfo(objectInfo: objectInfo)
							}
						}
					))
				if self.viewModel.showInfo {
					self.infoView()
						.frame(height: 250)
						.background(Color(UIColor.systemBackground))
				}
			}
			.edgesIgnoringSafeArea(.all)
			if self.viewModel.showCloseMenu {
				self.closeMenu
			}
			HStack {
				Spacer()
				VStack {
					Spacer()
					self.mapFactory.mapViewsFactory.makeZoomView()
					Spacer()
					self.mapFactory.mapViewsFactory.makeCurrentLocationView()
						.padding(.bottom, 40)
				}
				.padding(.trailing, 4)
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
		.navigationBarBackButtonHidden(true)
	}

	private func navigationBarTrailingItem() -> some View {
		NavigationLink(destination: SearchView(
			store: self.viewModel.searchStore,
			logger: self.viewModel.logger,
			directoryViewsFactory: self.directoryViewsFactory
		)) {
			Image(systemName: "magnifyingglass.circle.fill")
				.resizable()
				.frame(minWidth: 32, minHeight: 32)
		}
	}

	private var backButton: some View {
		Button(action: {
			self.viewModel.showCloseMenu = true
		}) {
			HStack {
				Image(systemName: "chevron.left")
				Text("Back")
			}
		}
	}

	private var closeMenu: some View {
		VStack {
			Text("Save search parameters?")
				.foregroundColor(.primary)
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

	private func infoView() -> some View {
		VStack(alignment: .leading, spacing: 10) {
			HStack {
				Text(self.viewModel.searchItemInfo.title).font(.title)
				Spacer()
				Button(
					action: { self.viewModel.showInfo = false },
					label: { Image(systemName: "xmark").foregroundColor(.gray) }
				)
			}
			.padding([.top, .trailing])
			Text(self.viewModel.searchItemInfo.subTitle).font(.subheadline)
			Text(self.viewModel.searchItemInfo.id)
			Text(self.viewModel.searchItemInfo.coordinate)
			Text(self.viewModel.searchItemInfo.address)
			Spacer()
		}
		.padding(10)
	}
}
