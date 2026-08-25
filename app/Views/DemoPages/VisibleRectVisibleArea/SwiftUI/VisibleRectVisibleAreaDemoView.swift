import SwiftUI
import DGis

struct VisibleRectVisibleAreaDemoView: View {
	typealias State = SwiftUI.State

	@Environment(\.presentationMode) private var presentationMode
	@ObservedObject private var viewModel: VisibleRectVisibleAreaDemoViewModel
	@State private var showInfo = false
	private let mapFactory: IMapFactory

	init(
		viewModel: VisibleRectVisibleAreaDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack {
			self.mapFactory.mapView
				.copyrightAlignment(.topLeft)
			ZStack(alignment: .top) {
				VStack(alignment: .trailing) {
					Spacer()
					HStack {
						self.visibleRectButton
						.frame(width: 55, height: 55)
						.fixedSize()
						.padding(20)
						Spacer()
						self.visibleAreaButton
						.frame(width: 55, height: 55)
						.fixedSize()
						.padding(20)
					}
				}
			}
			if self.showInfo {
				VisibleRectVisibleAreaInfoView(isPresented: self.$showInfo)
			}
		}
		.edgesIgnoringSafeArea(.all)
		.navigationBarBackButtonHidden(true)
		.navigationBarItems(leading: self.backButton, trailing: self.infoButton)
		.alert(isPresented: self.$viewModel.isErrorAlertShown) {
			Alert(title: Text(self.viewModel.errorMessage ?? ""))
		}
	}
	
	private var backButton : some View {
		Button(action: {
			self.presentationMode.wrappedValue.dismiss()
		}) {
			HStack {
				Image(systemName: "chevron.backward")
				Text("Back")
			}
		}
	}
	
	private var infoButton : some View {
		Button(action: {
			self.showInfo.toggle()
		}) {
			Image(systemName: self.showInfo ? "xmark" : "info.circle")
		}
	}
	
	private var visibleRectButton: some View {
		Button(action: {
			self.viewModel.isVisibleRectShown.toggle()
			self.viewModel.showVisibleRect()
		}) {
			ZStack {
				RoundedRectangle(cornerRadius: 10)
				.foregroundColor(Color(UIColor.systemBackground))
				.frame(width: 55, height: 55)
				.shadow(radius: 5)
				Image(systemName: self.viewModel.isVisibleRectShown ? "arrowtriangle.down.fill" : "arrowtriangle.down")
				.imageScale(.large)
				Image(systemName: "viewfinder")
				.imageScale(.large)
			}
			.font(.largeTitle)
			.foregroundColor(self.viewModel.isVisibleRectShown ? .green : .accentColor)
		}
	}
	
	private var visibleAreaButton: some View {
		Button(action: {
			self.viewModel.isVisibleAreaShown.toggle()
			self.viewModel.showVisibleArea()
		}) {
			ZStack {
				RoundedRectangle(cornerRadius: 10)
				.foregroundColor(Color(UIColor.systemBackground))
				.frame(width: 55, height: 55)
				.shadow(radius: 5)
				Image(systemName: self.viewModel.isVisibleAreaShown ? "arrowtriangle.down.fill" : "arrowtriangle.down")
				.font(.largeTitle)
				.imageScale(.large)
				.foregroundColor(self.viewModel.isVisibleAreaShown ? .orange : .accentColor)
			}
		}
	}
}
