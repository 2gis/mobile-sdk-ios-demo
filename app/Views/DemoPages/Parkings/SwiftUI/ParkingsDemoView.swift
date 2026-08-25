import DGis
import SwiftUI

struct ParkingsDemoView: View {
	@ObservedObject private var viewModel: ParkingsDemoViewModel
	private let mapFactory: IMapFactory

	init(
		viewModel: ParkingsDemoViewModel,
		mapFactory: IMapFactory
	) {
		self.viewModel = viewModel
		self.mapFactory = mapFactory
	}

	var body: some View {
		ZStack(alignment: .bottomTrailing) {
			ZStack(alignment: .center) {
				self.mapFactory.mapView
					.copyrightAlignment(.bottomLeft)
					.objectTappedCallback(callback: .init(
						callback: { [viewModel = self.viewModel] objectInfo in
							viewModel.handleTap(objectInfo: objectInfo)
						}
					))
				HStack {
					Spacer()
					VStack {
						Button {
							self.viewModel.isParkingsEnabled.toggle()
						} label: {
							Image(systemName: "parkingsign")
								.font(.system(size: 18, weight: .medium))
								.foregroundColor(self.viewModel.isParkingsEnabled ? SwiftUI.Color.blue : SwiftUI.Color.primary)
						}
						.frame(width: 44, height: 44)
						.background(
							Circle()
								.fill(Color(UIColor.systemBackground))
								.shadow(radius: 3)
						)

						self.mapFactory.mapViewsFactory.makeZoomView()
							.frame(width: 48, height: 102)
							.fixedSize()
							.padding(20)
						self.mapFactory.mapViewsFactory.makeCurrentLocationView()
							.frame(width: 48, height: 48)
							.fixedSize()
					}
				}
			}
		}
		.sheet(item: self.$viewModel.directoryObject, content: { directoryObject in
			NavigationView {
				ParkingInfoView(directoryObject: directoryObject)
					.navigationBarItems(leading: Button("Close", action: {
						self.viewModel.directoryObject = nil
					}))
			}
		})
		.edgesIgnoringSafeArea(.all)
	}
}

private struct ParkingInfoView: View {
	let directoryObject: DirectoryObject

	var body: some View {
		List {
			VStack(alignment: .leading) {
				self.makeValueDescription(name: "Object Title", value: self.directoryObject.title)
				self.makeValueDescription(
					name: "Object Type",
					value: self.directoryObject.types.map(\.name).joined(separator: ", ")
				)
				if let parkingInfo = self.directoryObject.parkingInfo {
					if let typeName = parkingInfo.type?.name {
						self.makeValueDescription(name: "Parking Type", value: typeName)
					}
					if let pavingTypeName = parkingInfo.pavingType?.name {
						self.makeValueDescription(name: "Paving Type", value: pavingTypeName)
					}
					self.makeValueDescription(name: "Purpose", value: parkingInfo.purpose.name)
					if let levelCount = parkingInfo.levelCount {
						self.makeValueDescription(name: "Number of Levels", value: "\(levelCount)")
					}
					self.makeBoolValueDescription(name: "Is the parking paid?", value: parkingInfo.isPaid)
					self.makeBoolValueDescription(name: "Is the parking intercept?", value: parkingInfo.isIncentive)
					self.makeBoolValueDescription(name: "Truck spaces available", value: parkingInfo.forTrucks)
					self.makeValueDescription(name: "Access Type", value: parkingInfo.access.name)
					if let capacity = parkingInfo.capacity {
						if let total = capacity.total {
							self.makeValueDescription(name: "Capacity", value: "\(total)")
						}
						if !capacity.specialSpaces.isEmpty {
							self.makeTitle("Description of special parking spaces:")
							ForEach(capacity.specialSpaces, id: \.self) { specialSpace in
								VStack(alignment: .leading) {
									self.makeValueDescription(
										name: "Name",
										value: specialSpace.name
									)
									self.makeValueDescription(
										name: "Type",
										value: specialSpace.type.name
									)
									if let count = specialSpace.count {
										self.makeValueDescription(
											name: "Number of spaces",
											value: count
										)
									}
								}
								.padding([.leading, .bottom])
							}
						}
					}
				}
			}
		}
	}

	private func makeBoolValueDescription(name: String, value: Bool) -> some View {
		self.makeValueDescription(name: name, value: value ? "Yes" : "No")
	}

	private func makeValueDescription(name: String, value: String) -> some View {
		self.makeTitle("\(name): ") +
			Text("\(value)").font(.system(size: 12, weight: .regular))
	}

	private func makeTitle(_ title: String) -> Text {
		Text(title).font(.system(size: 14, weight: .medium))
	}
}

extension DirectoryObject: @retroactive Identifiable {}

private extension ParkingType {
	var name: String {
		switch self {
		case .ground:
			return "Ground Parking"
		case .multilevel:
			return "Multilevel Parking"
		case .underground:
			return "Underground Parking"
		@unknown default:
			assertionFailure("Unknown ParkingType: \(self)")
			return "Unknown Type \(self.rawValue)"
		}
	}
}

private extension ParkingPurpose {
	var name: String {
		switch self {
		case .babyCarriage:
			return "For Baby Carriages"
		case .bike:
			return "For Bicycles"
		case .car:
			return "For Cars"
		case .motorbike:
			return "For Motorbikes/Mopeds"
		case .scooter:
			return "For Scooters"
		@unknown default:
			assertionFailure("Unknown ParkingPurpose: \(self)")
			return "Unknown Type \(self.rawValue)"
		}
	}
}

private extension ParkingPavingType {
	var name: String {
		switch self {
		case .asphalt:
			return "Asphalt Paving"
		case .concrete:
			return "Concrete Paving"
		case .gravel:
			return "Gravel Paving"
		case .unpaved:
			return "Unpaved"
		@unknown default:
			assertionFailure("Unknown ParkingPavingType: \(self)")
			return "Unknown Type \(self.rawValue)"
		}
	}
}

private extension ParkingAccess {
	var name: String {
		switch self {
		case .public:
			return "Public"
		case .customersOnly:
			return "Customers Only"
		case .handicappedOnly:
			return "Handicapped Only"
		case .residentsOnly:
			return "Residents Only"
		case .taxiOnly:
			return "Taxi Stand"
		@unknown default:
			assertionFailure("Unknown ParkingAccess: \(self)")
			return "Unknown Type \(self.rawValue)"
		}
	}
}

private extension SpecialSpaceType {
	var name: String {
		switch self {
		case .scooter:
			return "For Scooters"
		case .motorbike:
			return "For Motorbikes"
		case .babyCarriage:
			return "For Baby Carriages"
		case .bicycle:
			return "For Bicycles"
		case .family:
			return "For Families"
		case .handicapped:
			return "For Handicapped"
		case .truck:
			return "For Trucks"
		@unknown default:
			assertionFailure("Unknown SpecialSpaceType: \(self)")
			return "Unknown Type \(self.rawValue)"
		}
	}
}
