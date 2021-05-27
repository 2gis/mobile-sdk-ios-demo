import SwiftUI
import Combine
import PlatformSDK

final class MarkersDemoViewModel: ObservableObject {
	@Published var showMarkers: Bool = false
	let markerViewModel: MarkerViewModel

	init(
		map: Map,
		imageFactory: IImageFactory
	) {
		self.markerViewModel =  MarkerViewModel(
			map: map,
			imageFactory: imageFactory
		)
	}
}

