import SwiftUI
import DGis

struct MapSnapshotView: View {
	private enum Constants {
		static let cameraPosition = CameraPosition(
			point: GeoPoint(latitude: 55.7522200, longitude: 37.6155600),
			zoom: Zoom(value: 13.0)
		)
	}
	@Environment(\.presentationMode) private var presentationMode
	@SwiftUI.State private var mapSnapshotImage: UIImage? = nil
	@SwiftUI.State private var message: String = "Snapshot will appear here"
	@SwiftUI.State private var snapshotterCancellable: Cancellable?
	@SwiftUI.State private var moveCameraCancellable: Cancellable?
	private var dataLoadingStateChannelCancellable: Cancellable
	private let mapFactory: IMapFactory
	
	init(mapFactory: IMapFactory) {
		self.mapFactory = mapFactory
		self.dataLoadingStateChannelCancellable = self.mapFactory.map.dataLoadingStateChannel.sink { state in
			print("[Testing] \(state)")
		}
	}
	
	var body: some View {
		VStack {
			mapFactory.mapViewOverlay
			.frame(height: UIScreen.main.bounds.height / 2 - 40)

			HStack(spacing: 40) {
				Button(action: self.makeSnapshot) {
					Text("Make Snapshot")
						.frame(height: 20)
						.foregroundColor(.black)
						.padding()
						.background(Color.gray.opacity(0.7))
						.cornerRadius(8)
				}

				Button(action: closePressed) {
					Text("Close")
						.frame(height: 20)
						.foregroundColor(.black)
						.padding()
						.background(Color.gray.opacity(0.7))
						.cornerRadius(8)
				}
			}
			.padding(EdgeInsets(top: 10, leading: 0, bottom: 10, trailing: 0))

			if let snapshot = self.mapSnapshotImage {
				Image(uiImage: snapshot)
					.resizable()
					.aspectRatio(contentMode: .fit)
					.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2 - 40)
			} else {
				Text(self.message)
					.foregroundColor(.black)
					.multilineTextAlignment(.center)
					.padding()
					.frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height / 2 - 40)
					.background(Color.gray.opacity(0.2))
			}
		}
		.ignoresSafeArea(.all)
		.onAppear {
			self.moveToPosition()
		}
	}

	private func makeSnapshot() {
		let scale = UIScreen.main.scale
		let snapshotter = self.mapFactory.snapshotter
		self.snapshotterCancellable = snapshotter.makeImage(scale: scale, orientation: .up)
			.sinkOnMainThread(receiveValue: { image in
				self.mapSnapshotImage = image
				self.message = ""
			}, failure: { error in
				self.message = error.localizedDescription
			})
	}

	private func closePressed() {
		self.presentationMode.wrappedValue.dismiss()
	}
	
	private func moveToPosition() {
		_ = mapFactory.map.camera.move(
			position: Constants.cameraPosition,
			time: 0.2,
			animationType: .default
		).sinkOnMainThread(receiveValue: { _ in }, failure: { _ in })
	}
}
