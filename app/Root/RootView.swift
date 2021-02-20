import SwiftUI

struct RootView: View {
	private static let mapCoordinateSpace = "map"

	private let viewModel: RootViewModel
	private let viewFactory: RootViewFactory

	@State private var showMarkers: Bool = false
	@State private var showRoutes: Bool = false

	init(
		viewModel: RootViewModel,
		viewFactory: RootViewFactory
	) {
		self.viewModel = viewModel
		self.viewFactory = viewFactory
	}

	@State private var keyboardOffset: CGFloat = 0

	var body: some View {
		NavigationView  {
			ZStack() {
				ZStack(alignment: .bottomTrailing) {
					self.viewFactory.makeMapView()
					.coordinateSpace(name: Self.mapCoordinateSpace)
					.simultaneousGesture(self.drag)
					if !self.showMarkers {
						self.settingsButton().frame(width: 100, height: 100, alignment: .bottomTrailing)
					}
					if self.showMarkers {
						self.viewFactory.makeMarkerView(show: $showMarkers).followKeyboard($keyboardOffset)
					}
					if self.showRoutes {
						self.viewFactory.makeRouteView(show: $showRoutes).followKeyboard($keyboardOffset)
					}
				}
				if self.showMarkers || self.showRoutes {
					Image(systemName: "multiply").frame(width: 40, height: 40, alignment: .center).foregroundColor(.red).opacity(0.4)
				}
				self.zoomControls()
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

	private func zoomControls() -> some View {
		HStack {
			Spacer()
			self.viewFactory.makeZoomControl()
				.frame(width: 60, height: 128)
				.fixedSize()
				.transformEffect(.init(scaleX: 0.8, y: 0.8))
				.padding(10)
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
		.padding(.bottom, 40)
		.padding(.trailing, 20)
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
						self.showMarkers = true
					},
					.default(Text("Тест поиска маршрута")) {
						self.showRoutes = true
					},
					.cancel(Text("Отмена"))
				])
		}
	}

	private var drag: some Gesture {
		DragGesture(
			minimumDistance: 0,
			coordinateSpace: .named(Self.mapCoordinateSpace)
		)
		.onEnded { info in
			self.viewModel.tap(info.location)
		}
	}
}

