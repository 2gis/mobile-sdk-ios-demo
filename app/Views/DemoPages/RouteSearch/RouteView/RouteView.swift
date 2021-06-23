import SwiftUI

//struct RouteView: View {
//	@ObservedObject private var viewModel: RouteViewModel
//	@Binding var show: Bool
//
//	init(
//		viewModel: RouteViewModel,
//		show: Binding<Bool>
//	) {
//		self.viewModel = viewModel
//		self._show = show
//	}
//
//	var body: some View {
//		VStack(spacing: 12.0) {
//			DetailsActionView(action: {
//				self.viewModel.setupPointA()
//			}, primaryText: "Установить", detailsText: self.viewModel.pointADescription)
//			DetailsActionView(action: {
//				self.viewModel.setupPointB()
//			}, primaryText: "Установить", detailsText: self.viewModel.pointBDescription)
//			if self.viewModel.hasRoutes && !self.viewModel.hasBuiltRoute {
//				DetailsActionView(action: {
//					self.viewModel.findRoute()
//				}, primaryText: "Построить маршрут")
//			}
//			if self.viewModel.hasBuiltRoute {
//				DetailsActionView(action: {
//					self.viewModel.removeRoute()
//				}, primaryText: "Снести маршрут")
//			}
//			DetailsActionView(action: {
//				self.show = false
//			}, primaryText: "Закрыть")
//		}
//		.padding([.trailing], 40.0)
//		.padding([.bottom], 60.0)
//	}
//}


