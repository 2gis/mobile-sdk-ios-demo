import CoreLocation
import DGis
import SwiftUI

struct GeoPointPickerView: View {
	@Binding private var geoPoint: GeoPoint?
	@SwiftUI.State private var latitudeRawValue: String
	@SwiftUI.State private var longitudeRawValue: String
	private var isValid: Bool {
		!self.latitudeRawValue.isEmpty && !self.longitudeRawValue.isEmpty && self.geoPoint != nil
	}

	init(geoPoint: Binding<GeoPoint?>) {
		self._geoPoint = geoPoint
		self._latitudeRawValue = State(initialValue: geoPoint.wrappedValue.map { "\($0.latitude.value)" } ?? "")
		self._longitudeRawValue = State(initialValue: geoPoint.wrappedValue.map { "\($0.longitude.value)" } ?? "")
	}

	var body: some View {
		VStack(alignment: .leading) {
			if !self.latitudeRawValue.isEmpty, !self.longitudeRawValue.isEmpty {
				HStack {
					Text("{ \(self.latitudeRawValue), \(self.longitudeRawValue) }")
						.font(.headline)
						.foregroundColor(self.geoPoint == nil ? .red : .green)
					Image(systemName: "xmark")
						.resizable()
						.frame(width: 20, height: 20)
						.foregroundColor(.red)
						.onTapGesture {
							self.removeGeoPoint()
						}
				}
			}

			HStack {
				HStack {
					Text("Lat:")
					TextField("Enter a value", text: Binding<String>(
						get: {
							self.latitudeRawValue
						},
						set: { rawValue in
							self.latitudeRawValue = rawValue
							self.updateGeoPoint()
						}))
						.keyboardType(.numbersAndPunctuation)
				}
				HStack {
					Text("Lon:")
					TextField("Enter a value", text: Binding<String>(
						get: {
							self.longitudeRawValue
						},
						set: { rawValue in
							self.longitudeRawValue = rawValue
							self.updateGeoPoint()
						}))
						.keyboardType(.numbersAndPunctuation)
				}
			}
		}
	}

	private func removeGeoPoint() {
		self.latitudeRawValue = ""
		self.longitudeRawValue = ""
		self.updateGeoPoint()
	}

	private func updateGeoPoint() {
		var newGeoPoint: GeoPoint?
		if let latitude = Double(self.latitudeRawValue),
		   let longitude = Double(self.longitudeRawValue),
		   CLLocationCoordinate2DIsValid(CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
		{
			newGeoPoint = GeoPoint(latitude: .init(value: latitude), longitude: .init(value: longitude))
		}
		if newGeoPoint != self.geoPoint {
			self.geoPoint = newGeoPoint
		}
	}
}
