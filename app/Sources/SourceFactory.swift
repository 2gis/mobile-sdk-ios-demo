import PlatformSDK

protocol SourceFactory {
	func makeMyLocationMapObjectSource(
		behaviour: MyLocationDirectionBehaviour
	) -> MyLocationMapObjectSource
}

final class SDKSourceFactory: SourceFactory {
	private let context: PlatformSDK.Context

	init(context: PlatformSDK.Context) {
		self.context = context
	}

	func makeMyLocationMapObjectSource(
		behaviour: MyLocationDirectionBehaviour
	) -> MyLocationMapObjectSource {
		PlatformSDK.createMyLocationMapObjectSource(
			context: self.context,
			directionBehaviour: behaviour
		)
	}
}
