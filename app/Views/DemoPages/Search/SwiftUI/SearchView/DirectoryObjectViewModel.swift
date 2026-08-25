import DGis
import Foundation

struct DirectoryObjectViewModel: Identifiable {
	let id = UUID()
	let navigationTitle: String
	let title: String
	let subtitle: String
	let description: String
	let markerPosition: GeoPointWithElevation?
	let address: FormattedAddressViewModel?
	let distanceToObject: Meter?
	let contextAttributes: String
	let attributes: String
	let openingHours: String
	let objectId: String
	let chargingStation: ChargingStation?
	let reviews: Reviews?
	let fiasCode: String?
	let tradeLicense: String
	let buildingInfo: String

	init(object: DirectoryObject, lastLocation: GeoPoint?) {
		self.navigationTitle = object.title
		self.title = object.title
		self.subtitle = object.subtitle
		self.description = object.description
		self.objectId = object.id?.objectId.description ?? ""
		self.reviews = object.reviews
		self.chargingStation = object.chargingStation
		self.fiasCode = object.address?.fiasCode
		self.markerPosition = object.markerPosition

		let formattedAddress = object.formattedAddress(type: .full)
		self.address = formattedAddress.map {
			FormattedAddressViewModel(address: $0, addressComponents: object.address?.components ?? [])
		}

		if let location = lastLocation {
			self.distanceToObject = self.markerPosition?.distance(point: location)
		} else {
			self.distanceToObject = nil
		}

		let contextAttributesArray = object.contextAttributes.map { "\($0.tag): \($0.value)" }
		let attributesArray = object.attributes.map { "\($0.tag): \($0.value)" }
		self.contextAttributes = contextAttributesArray.joined(separator: ", ")
		self.attributes = attributesArray.joined(separator: ", ")
		var openingHoursArray: [String] = []
		object.openingHours?.weekOpeningHours.forEach { workTime in
			openingHoursArray.append(contentsOf: workTime.map {
				"\($0.startTime.weekDay.name): \($0.startTime.time.hours):\(String(format: "%02d", $0.startTime.time.minutes))-\($0.finishTime.time.hours):\(String(format: "%02d", $0.finishTime.time.minutes))"
			})
		}
		self.openingHours = openingHoursArray.joined(separator: "\n")
		self.tradeLicense = object.tradeLicense.map {
			"""
			Type: \($0.type)
			License: \($0.license)
			LegalForm: \($0.legalForm)
			EndDate: \($0.endDate)
			"""
		} ?? ""

		let buildingLevels = object.buildingInfo?.buildingLevels?.levels.map {
			"   \(String(describing: $0.id)): \($0.name)"
		} ?? []
		self.buildingInfo = """
		BuildingName: \(object.buildingInfo?.buildingName ?? "")
		PurposeName: \(object.buildingInfo?.purposeName ?? "")
		PurposeCode: \(object.buildingInfo?.purposeCode.map { String($0.value) } ?? "")
		BuildingLevels: \n\(buildingLevels.joined(separator: "\n"))
		"""
	}
}
