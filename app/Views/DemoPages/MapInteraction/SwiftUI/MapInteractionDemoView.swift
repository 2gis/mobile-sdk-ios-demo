import SwiftUI
import DGis

/// Demo for testing map interactivity disablement.
/// Do not migrate to the demo project.
struct MapInteractionDemoView: View {
	@SwiftUI.State private var interactionStates: [Bool]
	private var mapFactories: [IMapFactory]
	private let mapFactoryProvider: () -> IMapFactory
	private let mapHeight: CGFloat

	init(mapFactoryProvider: @escaping () -> IMapFactory) {
		self.mapFactoryProvider = mapFactoryProvider
		self.mapFactories = [
			self.mapFactoryProvider(),
			self.mapFactoryProvider(),
			self.mapFactoryProvider()
		]
		self._interactionStates = State(initialValue: Array(repeating: true, count: self.mapFactories.count))
		self.mapHeight = max(UIScreen.main.bounds.height, UIScreen.main.bounds.width) / CGFloat(self.mapFactories.count)
	}

	var body: some View {
		VStack(spacing: 0) {
			ForEach(0..<self.self.mapFactories.count, id: \.self) { index in
				ZStack(alignment: .bottomLeading) {
					self.mapFactories[index].mapViewOverlay
					Toggle("", isOn: $interactionStates[index])
						.toggleStyle(SwitchToggleStyle(tint: .accentColor))
						.labelsHidden()
						.padding()
				}
				.frame(height: self.mapHeight)
				.onChange(of: interactionStates[index]) { newValue in
					self.mapFactories[index].map.interactive = newValue
				}
			}
		}
		.ignoresSafeArea(.all)
	}
}
