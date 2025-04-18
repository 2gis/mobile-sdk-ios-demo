import DGis
import UIKit

class MapMarkerPresenter {
	private enum Constants {
		static let animationDuration = 0.5
		static let hideMarkerAlpha = 0.3
	}

	private let markerViewFactory: (MapMarkerUIView, GeoPointWithElevation) -> IMarkerView
	private var addMarkerViewCallback: ((IMarkerView) -> Void)? = nil
	private var removeMarkerViewCallback: ((IMarkerView) -> Void)? = nil

	init(
		markerViewFactory: @escaping (MapMarkerUIView, GeoPointWithElevation) -> IMarkerView
	) {
		self.markerViewFactory = markerViewFactory
	}

	func setAddMarkerViewCallback(addMarkerViewCallback: @escaping (IMarkerView) -> Void) {
		self.addMarkerViewCallback = addMarkerViewCallback
	}

	func setRemoveMarkerViewCallback(removeMarkerViewCallback: @escaping (IMarkerView) -> Void) {
		self.removeMarkerViewCallback = removeMarkerViewCallback
	}

	func showMarkerView(viewModel: MapObjectCardViewModel) {
		viewModel.titleChangedCallback = { [weak self, position = viewModel.objectPosition] title, subtitle in
			guard
				let self = self,
				let addMarkerViewCallback = self.addMarkerViewCallback
			else {
				return
			}

			UIViewPropertyAnimator(duration: Constants.animationDuration, curve: .easeOut, animations: {
				let mapMarkerViewModel = MapMarkerUIViewModel(title: title, subtitle: subtitle)
				let mapMarkerView = MapMarkerUIView(viewModel: mapMarkerViewModel)
				let markerView = self.markerViewFactory(mapMarkerView, position)

				markerView.tapHandler = { [weak markerView, weak self] in
					if let marker = markerView {
						self?.hide(markerView: marker)
					}
				}

				addMarkerViewCallback(markerView)
			}).startAnimation()
		}
	}

	private func hide(markerView: IMarkerView) {
		guard let removeMarkerViewCallback = self.removeMarkerViewCallback else {
			return
		}

		UIView.animate(
			withDuration: Constants.animationDuration,
			delay: 0.0,
			options: .curveEaseIn,
			animations: {
				markerView.alpha = Constants.hideMarkerAlpha
			},
			completion: { _ in
				removeMarkerViewCallback(markerView)
			}
		)
	}
}
