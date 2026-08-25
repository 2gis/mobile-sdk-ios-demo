import SwiftUI
import DGis

struct BenchmarkView: View {
	private enum Constants {
		static let graphHeight: CGFloat = 100
	}

	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject private var viewModel: BenchmarkViewModel
	private let mapFactory: IMapFactory

	init(
		viewModel: BenchmarkViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		GeometryReader { geometry in
			ZStack {
				ZStack(alignment: .bottomTrailing) {
					self.mapFactory.mapView
						.showsAPIVersion(true)
						.copyrightAlignment(.bottomRight)
						.copyrightInsets(
							EdgeInsets(
								top: 0,
								leading: 0,
								bottom: Constants.graphHeight - geometry.safeAreaInsets.bottom,
								trailing: 0
							)
					)
					FPSGraphView(viewModel: viewModel)
					.frame(height: Constants.graphHeight)
				}
				.edgesIgnoringSafeArea(.all)
			}
			.actionSheet(isPresented: self.$viewModel.showActionSheet) { self.benchmarkMenu	}
			.navigationBarBackButtonHidden(true)
			.navigationBarItems(leading: self.backButton, trailing: self.viewModel.showMenuButton ? self.menuButton : nil)
		}
	}

	private var benchmarkMenu: ActionSheet {
		ActionSheet(
			title: Text("Benchmark scenarios"),
			buttons: BenchmarkPath.allCases.map { benchmarkPath in
					.default(Text(benchmarkPath.name)) {
						self.viewModel.showMenuButton = false
						self.viewModel.runTest(benchmarkPath: benchmarkPath)
					}
			} + [.cancel(Text("Cancel"))]
		)
	}

	private var backButton: some View {
		Button(
			action: {
				self.presentationMode.wrappedValue.dismiss()
			}) {
			HStack {
				Image(systemName: "chevron.backward")
				Text("Back")
			}
		}
	}

	private var menuButton: some View {
		Button(action: {
			self.viewModel.showActionSheet = true
		}) {
			Image(systemName: "list.bullet")
		}
	}
}
