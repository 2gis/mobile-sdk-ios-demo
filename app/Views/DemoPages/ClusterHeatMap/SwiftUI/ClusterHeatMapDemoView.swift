import DGis
import SwiftUI

struct ClusterHeatMapDemoView: View {
	typealias State = SwiftUI.State

	@ObservedObject private var viewModel: ClusterHeatMapDemoViewModel
	@State private var mapViewsFactory: IMapViewsFactory?
	private let mapFactory: IMapFactory

	init(viewModel: ClusterHeatMapDemoViewModel, mapFactory: IMapFactory) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack {
			self.mapFactory.mapView
				.copyrightAlignment(.bottomLeft)
				.edgesIgnoringSafeArea(.all)

			self.mapControls

			VStack(spacing: 12.0) {
				self.descriptionCard
				Spacer()
				Button(action: self.viewModel.resetCamera) {
					Label("Reset Moscow", systemImage: "scope")
						.font(.subheadline.weight(.semibold))
						.padding(.horizontal, 16.0)
						.padding(.vertical, 10.0)
				}
				.buttonStyle(.borderedProminent)
				.disabled(!self.viewModel.isReady)
			}
			.padding(.horizontal, 16.0)
			.padding(.top, 12.0)
			.padding(.bottom, 24.0)
		}
		.alert(isPresented: self.$viewModel.isErrorAlertShown) {
			Alert(title: Text(self.viewModel.errorMessage ?? "Heat map error"))
		}
		.task {
			guard self.mapViewsFactory == nil else { return }
			guard (try? await self.mapFactory.mapAsync) != nil else { return }
			self.mapViewsFactory = self.mapFactory.mapViewsFactory
		}
	}

	private var descriptionCard: some View {
		VStack(alignment: .leading, spacing: 7.0) {
			Text("Cluster heat map · Moscow")
				.font(.headline)
			Text("Each point has db_intensity. At any zoom, the intensity of a spot is the sum of its points; clusters and individual spots use the same blurred radius.")
				.font(.footnote)
				.foregroundColor(.secondary)
			LinearGradient(
				colors: [.orange.opacity(0.12), .orange.opacity(0.42), .orange.opacity(0.95)],
				startPoint: .leading,
				endPoint: .trailing
			)
			.frame(height: 8.0)
			.clipShape(Capsule())
			HStack {
				Text("Lower intensity")
				Spacer()
				Text("Higher intensity")
			}
			.font(.caption2)
			.foregroundColor(.secondary)
		}
		.padding(14.0)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(.ultraThinMaterial)
		.cornerRadius(14.0)
	}

	@ViewBuilder
	private var mapControls: some View {
		if let mapViewsFactory {
			HStack {
				Spacer()
				VStack {
					Spacer()
					mapViewsFactory.makeZoomView()
						.frame(width: 48.0, height: 102.0)
						.fixedSize()
					Spacer()
				}
			}
			.padding(.trailing, 16.0)
		}
	}
}
