import Combine
import DGis
import SwiftUI

@MainActor
final class CameraRestrictionsDemoViewModel: ObservableObject {
	private enum Constants {
		static let defaultMinZoom: Float = 0.0
		static let defaultMaxZoom: Float = 20.0
		static let defultMapTiltRelationPoints: [RelationPoint] = [
			.init(zoom: 14.0, tilt: 30.0),
			.init(zoom: 16.0, tilt: 70.0),
		]
		static let defaultZoomToTiltRelationPoints: [RelationPoint] = [
			.init(zoom: 15.6, tilt: 0.0),
			.init(zoom: 16.7, tilt: 17.0),
			.init(zoom: 17.3, tilt: 24.0),
		]
	}

	@Published var cameraPosition: String = ""
	@Published var minZoom = Constants.defaultMinZoom
	@Published var maxZoom = Constants.defaultMaxZoom
	@Published var maxTiltRelationPoints = Constants.defultMapTiltRelationPoints
	@Published var zoomToTiltRelationPoints = Constants.defaultZoomToTiltRelationPoints
	@Published var isErrorAlertShown: Bool = false

	private let map: Map
	private let logger: ILogger
	private var followController: FollowController
	private var cameraPositionCancellable: ICancellable?

	private(set) var errorMessage: String? {
		didSet {
			self.isErrorAlertShown = self.errorMessage != nil
		}
	}

	init(
		map: Map,
		logger: ILogger,
		mapSourceFactory: IMapSourceFactory
	) {
		self.map = map
		self.logger = logger
		self.followController = TiltFollowController(styleZoomToTilt: createDefaultStyleZoomToTiltRelation())
		let locationSource = mapSourceFactory.makeSmoothMyLocationMapObjectSource(bearingSource: .auto)
		self.map.addSource(source: locationSource)
		self.applySettings()
		self.setupCameraPositionChannel()
	}

	func applySettings() {
		self.setZoomToTiltRestrictions()
		self.setZoomRestrictions()
		self.setStyleZoomToTiltRelation()
	}

	func followControllerButtonClick() {
		self.map.camera.setBehaviour(behaviour: .init(position: FollowPosition(bearing: .on, styleZoom: .on), tilt: .on))
	}

	private func setupCameraPositionChannel() {
		self.cameraPositionCancellable = self.map.camera.sinkOnStatefulChangesOnMainThread(reason: .position) {
			[weak self] (position: CameraPosition) in
			Task { @MainActor [weak self] in
				guard let self else { return }
				self.cameraPosition =
					String(format: "lat: %.6f ", position.point.latitude.value) +
					String(format: "lon: %.6f\n", position.point.longitude.value) +
					String(format: "zoom: %.2f ", position.zoom.value) +
					String(format: "tilt: %.2f ", position.tilt.value) +
					String(format: "bearing: %.2f", position.bearing.value)
			}
		}
	}

	private func setZoomToTiltRestrictions() {
		guard !self.maxTiltRelationPoints.isEmpty else {
			self.map.camera.maxTiltRestriction = .none
			return
		}
		guard self.isValid(points: self.maxTiltRelationPoints) else {
			self.errorMessage = "Error:\nTilt sequence must be ordered"
			return
		}
		let points = self.maxTiltRelationPoints.reduce(into: [StyleZoom: Tilt]()) { relation, point in
			let zoom = StyleZoom(floatLiteral: point.zoom)
			let tiltValue = Tilt(value: point.tilt)
			relation[zoom] = tiltValue
		}
		self.map.camera.maxTiltRestriction = createStyleZoomToTiltRelation(points: points)
	}

	private func setStyleZoomToTiltRelation() {
		guard self.isValid(points: self.zoomToTiltRelationPoints) else {
			self.errorMessage = "Error:\nTilt sequence must be ordered"
			return
		}
		self.map.camera.removeFollowController(followController: self.followController)
		if self.zoomToTiltRelationPoints.isEmpty {
			self.errorMessage = "Must be set at least one zoom to tilt relation point. Set to default values"
			DispatchQueue.main.async {
				self.zoomToTiltRelationPoints = Constants.defaultZoomToTiltRelationPoints
			}
		}
		let points = self.zoomToTiltRelationPoints.reduce(into: [StyleZoom: Tilt]()) { relation, point in
			let zoom = StyleZoom(floatLiteral: point.zoom)
			let tiltValue = Tilt(value: point.tilt)
			relation[zoom] = tiltValue
		}
		let styleZoomToTiltRelation = createStyleZoomToTiltRelation(points: points)
		self.followController = TiltFollowController(styleZoomToTilt: styleZoomToTiltRelation)
		self.map.camera.addFollowController(followController: self.followController)
	}

	private func setZoomRestrictions() {
		do {
			try self.map.camera.setZoomRestrictions(zoomRestrictions: .init(
				minZoom: Zoom(value: self.minZoom),
				maxZoom: Zoom(value: self.maxZoom)
			))
		} catch let error as SimpleError {
			self.errorMessage = error.description
		} catch {
			self.errorMessage = error.localizedDescription
		}
	}

	private func isValid(points: [RelationPoint]) -> Bool {
		let sortedPoints = points.sorted { $0.zoom < $1.zoom }
		for i in 1 ..< sortedPoints.count {
			if sortedPoints[i].tilt < sortedPoints[i - 1].tilt {
				return false
			}
		}
		return true
	}
}
