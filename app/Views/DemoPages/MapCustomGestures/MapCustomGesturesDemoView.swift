import DGis
import SwiftUI

struct MapCustomGesturesDemoView: View {
	private enum Constants {
		static let iconSize: CGSize = .init(width: 30, height: 30)
	}

	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject private var viewModel: MapCustomGesturesDemoViewModel
	private let mapFactory: IMapFactory
	private let gestureView: any UIView & IMapGestureUIView

	init(
		viewModel: MapCustomGesturesDemoViewModel,
		mapFactory: IMapFactory,
		gestureView: any UIView & IMapGestureUIView
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
		self.gestureView = gestureView
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			self.mapFactory.mapView
				.gestureView(self.gestureView)
				.showsAPIVersion(true)
				.copyrightAlignment(.bottomLeft)
				.edgesIgnoringSafeArea(.all)

			VStack {
				Spacer()
				HStack {
					Spacer()
					self.gestureButtons
						.padding(.trailing, 20)
				}
			}
		}
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: self.backButton)
	}

	private var backButton: some View {
		Button(action: { self.presentationMode.wrappedValue.dismiss() }) {
			HStack {
				Image(systemName: "chevron.backward")
				Text("Back")
			}
		}
	}

	private var gestureButtons: some View {
		HStack {
			VStack {
				HStack {
					Button(action: { self.viewModel.mapRotationEvent(.counterClockwise) }) {
						self.makeButtonImage(systemName: "arrow.counterclockwise")
					}
					Spacer()
					Button(action: { self.viewModel.mapShiftEvent(.top) }) {
						self.makeButtonImage(systemName: "chevron.up")
					}
					Spacer()
					Button(action: { self.viewModel.mapRotationEvent(.clockwise) }) {
						self.makeButtonImage(systemName: "arrow.clockwise")
					}
				}
				HStack {
					Button(action: { self.viewModel.mapShiftEvent(.left) }) {
						self.makeButtonImage(systemName: "chevron.left")
					}
					Spacer()
					Button(action: { self.viewModel.mapShiftEvent(.right) }) {
						self.makeButtonImage(systemName: "chevron.right")
					}
				}
				HStack {
					Button(action: { self.viewModel.mapTiltEvent(.down) }) {
						self.makeButtonImage(systemName: "arrow.down.square")
					}
					Spacer()
					Button(action: { self.viewModel.mapShiftEvent(.down) }) {
						self.makeButtonImage(systemName: "chevron.down")
					}
					Spacer()
					Button(action: { self.viewModel.mapTiltEvent(.up) }) {
						self.makeButtonImage(systemName: "arrow.up.square")
					}
				}
			}
			VStack {
				Button(action: { self.viewModel.mapScalingEvent(.zoomIn) }) {
					self.makeButtonImage(systemName: "plus.magnifyingglass")
				}
				Spacer()
				Button(action: { self.viewModel.mapScalingEvent(.zoomOut) }) {
					self.makeButtonImage(systemName: "minus.magnifyingglass")
				}
			}
		}
		.padding()
		.fixedSize()
		.background(Color(.systemBackground).opacity(0.6))
		.clipShape(RoundedRectangle(cornerRadius: 8))
	}

	private func makeButtonImage(systemName: String) -> some View {
		Image(systemName: systemName)
			.renderingMode(.template)
			.resizable()
			.aspectRatio(contentMode: .fit)
			.frame(width: Constants.iconSize.width, height: Constants.iconSize.height)
	}
}
