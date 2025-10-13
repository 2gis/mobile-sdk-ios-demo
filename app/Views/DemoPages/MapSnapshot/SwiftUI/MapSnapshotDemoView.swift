import DGis
import SwiftUI

struct MapSnapshotDemoView: View {
	@Environment(\.presentationMode) private var presentationMode
	@EnvironmentObject private var navigationService: NavigationService
	@ObservedObject private var viewModel: MapSnapshotDemoViewModel
	private let mapFactory: IMapFactory

	@SwiftUI.State private var foregroundObserver: NSObjectProtocol?

	init(
		viewModel: MapSnapshotDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			self.mapFactory.mapView
				.copyrightAlignment(.bottomLeft)
			VStack(spacing: 6.0) {
				self.settingsButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
				self.mapSnapshotButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
			}
			.padding(.bottom, 40)
			.padding(.trailing, 20)
		}
		.edgesIgnoringSafeArea(.all)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: self.backButton)
	}

	private func settingsButton() -> some View {
		Button.makeCircleButton(iconName: "pin.fill") {
			self.removeObserver()
			self.foregroundObserver = NotificationCenter.default.addObserver(
				forName: UIApplication.willEnterForegroundNotification,
				object: nil,
				queue: nil
			) { _ in
				Task { @MainActor in
					self.showMapSnapshotView()
				}
			}
		}
	}

	private func mapSnapshotButton() -> some View {
		Button.makeCircleButton(iconName: "map.fill") {
			self.showMapSnapshotView()
		}
	}

	private func showMapSnapshotView() {
		self.navigationService.push(self.viewModel.makeMapSnapshotView())
	}

	private var backButton: some View {
		Button(action: {
			self.removeObserver()
			self.presentationMode.wrappedValue.dismiss()
		}) {
			HStack {
				Image(systemName: "arrow.left.circle")
				Text("Back")
			}
		}
	}

	private func removeObserver() {
		if let foregroundObserver {
			NotificationCenter.default.removeObserver(foregroundObserver)
			self.foregroundObserver = nil
		}
	}
}
