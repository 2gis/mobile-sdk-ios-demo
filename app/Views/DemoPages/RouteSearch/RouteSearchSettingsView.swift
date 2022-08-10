import SwiftUI
import DGis

struct RouteSearchSettingsView: View {
	@Binding private var shown: Bool
	@Binding private var transportType: TransportType
	@Binding private var carRouteSearchOptions: CarRouteSearchOptions
	@Binding private var publicTransportRouteSearchOptions: PublicTransportRouteSearchOptions
	@Binding private var bicycleRouteSearchOptions: BicycleRouteSearchOptions
	@Binding private var pedestrianRouteSearchOptions: PedestrianRouteSearchOptions
	@Binding private var taxiRouteSearchOptions: TaxiRouteSearchOptions
	@Binding private var truckRouteSearchOptions: TruckRouteSearchOptions

	init(
		shown: Binding<Bool>,
		transportType: Binding<TransportType>,
		carRouteSearchOptions: Binding<CarRouteSearchOptions>,
		publicTransportRouteSearchOptions: Binding<PublicTransportRouteSearchOptions>,
		truckRouteSearchOptions: Binding<TruckRouteSearchOptions>,
		taxiRouteSearchOptions: Binding<TaxiRouteSearchOptions>,
		bicycleRouteSearchOptions: Binding<BicycleRouteSearchOptions>,
		pedestrianRouteSearchOptions: Binding<PedestrianRouteSearchOptions>
	) {
		self._shown = shown
		self._transportType = transportType
		self._carRouteSearchOptions = carRouteSearchOptions
		self._publicTransportRouteSearchOptions = publicTransportRouteSearchOptions
		self._truckRouteSearchOptions = truckRouteSearchOptions
		self._taxiRouteSearchOptions = taxiRouteSearchOptions
		self._bicycleRouteSearchOptions = bicycleRouteSearchOptions
		self._pedestrianRouteSearchOptions = pedestrianRouteSearchOptions
	}

	var body: some View {
		NavigationView {
			List {
				self.makeTransportTypePicker()
				.padding(.bottom, 5)
				self.makeCarRouteSearchOptionsView()
				.padding(.bottom, 5)
				self.makePublicTransportRouteSearchOptionsView()
				.padding(.bottom, 5)
				self.makeTruckRouteSearchOptionsView()
				.padding(.bottom, 5)
				self.makeTaxiRouteSearchOptionsView()
				.padding(.bottom, 5)
				self.makeBicycleRouteSearchOptionsView()
				.padding(.bottom, 5)
			}
			.navigationBarTitle(Text("Settings"), displayMode: .inline)
			.navigationBarItems(
				trailing: Button("Close", action: {
					self.shown = false
				})
			)
		}
	}

	private func makeTransportTypePicker() -> some View {
		PickerView(
			title: "Transport type:",
			selection: self.$transportType,
			options: TransportType.allCases,
			pickerStyle: WheelPickerStyle()
		)
	}

	private func makeCarRouteSearchOptionsView() -> some View {
		VStack(alignment: .leading) {
			self.makeSectionTitle("Car:")
			self.makeCarRouteSearchOptionsContent(
				avoidTollRoads: self.$carRouteSearchOptions.avoidTollRoads,
				avoidUnpavedRoads: self.$carRouteSearchOptions.avoidUnpavedRoads,
				avoidFerry: self.$carRouteSearchOptions.avoidFerries,
				routeSearchType: self.$carRouteSearchOptions.routeSearchType
			)
		}
	}

	@ViewBuilder
	private func makeCarRouteSearchOptionsContent(
		avoidTollRoads: Binding<Bool>,
		avoidUnpavedRoads: Binding<Bool>,
		avoidFerry: Binding<Bool>,
		routeSearchType: Binding<RouteSearchType>
	) -> some View {
		Toggle(isOn: avoidTollRoads, label: {
			self.makeOptionTitle("Avoid toll roads")
		})
		Toggle(isOn: avoidUnpavedRoads, label: {
			self.makeOptionTitle("Avoid unpaved roads")
		})
		Toggle(isOn: avoidFerry, label: {
			self.makeOptionTitle("Avoid ferry")
		})
		PickerView(
			title: "Route search type",
			selection: routeSearchType,
			options: RouteSearchType.availableTypes,
			pickerStyle: SegmentedPickerStyle()
		)
	}

	private func makePublicTransportRouteSearchOptionsView() -> some View {
		VStack(alignment: .leading) {
			self.makeSectionTitle("Public transport:")
			Toggle(isOn: self.$publicTransportRouteSearchOptions.useSchedule, label: {
				self.makeOptionTitle("Use schedule")
			})
			RouteSearchSettingsDatePicker(
				title: "Time in UTC for which you want to build a route.",
				subtitle: "If not set, the current time is used.",
				date: self.$publicTransportRouteSearchOptions.startTime
			)
			self.makePublicTransportTypePicker()
			.padding(.top, 10)
		}
	}

	@ViewBuilder
	private func makePublicTransportTypePicker() -> some View {
		self.makeOptionTitle("Public transport type")
		Text("If not filled, routes will be built for all supported types of public transport.")
		.fontWeight(.light)
		.foregroundColor(.primaryTitle)
		.fixedSize(horizontal: false, vertical: true)
		ForEach(PublicTransportTypeOptionSet.availableTypes) { type in
			HStack {
				Text(type.name)
				.fixedSize(horizontal: false, vertical: true)
				Spacer()
				if self.publicTransportRouteSearchOptions.transportTypes.contains(type) {
					Image(systemName: "checkmark.circle")
					.resizable()
					.frame(width: 20, height: 20)
					.foregroundColor(.blue)
				} else {
					Image(systemName: "circle")
					.resizable()
					.frame(width: 20, height: 20)
					.foregroundColor(.blue)
				}
			}
			.frame(height: 30)
			.onTapGesture {
				if self.publicTransportRouteSearchOptions.transportTypes.remove(type) == nil {
					self.publicTransportRouteSearchOptions.transportTypes.insert(type)
				}
			}
		}
	}

	private func makeTruckRouteSearchOptionsView() -> some View {
		VStack(alignment: .leading) {
			self.makeSectionTitle("Truck:")
			Toggle(isOn: self.$truckRouteSearchOptions.dangerousCargo, label: {
				self.makeOptionTitle("Dangerous cargo")
			})
			Toggle(isOn: self.$truckRouteSearchOptions.explosiveCargo, label: {
				self.makeOptionTitle("Explosive cargo")
			})
			self.makeCarRouteSearchOptionsContent(
				avoidTollRoads: self.$truckRouteSearchOptions.car.avoidTollRoads,
				avoidUnpavedRoads: self.$truckRouteSearchOptions.car.avoidUnpavedRoads,
				avoidFerry: self.$truckRouteSearchOptions.car.avoidFerries,
				routeSearchType: self.$truckRouteSearchOptions.car.routeSearchType
			)
			self.makeTruckFieldSetting()
			self.makeTruckPassIdPicker()
		}
	}

	@ViewBuilder
	private func makeTruckFieldSetting() -> some View {
		SettingsFormTextField(
			title: "Truck length in mm",
			value: self.$truckRouteSearchOptions.truckLength
		)
		SettingsFormTextField(
			title: "Truck height in mm",
			value: self.$truckRouteSearchOptions.truckHeight
		)
		SettingsFormTextField(
			title: "Truck width in mm",
			value: self.$truckRouteSearchOptions.truckWidth
		)
		SettingsFormTextField(
			title: "Actual truck mass in kg",
			value: self.$truckRouteSearchOptions.actualMass
		)
		SettingsFormTextField(
			title: "Max permitted truck mass in kg",
			value: self.$truckRouteSearchOptions.maxPermittedMass
		)
		SettingsFormTextField(
			title: "Axle load in kg",
			value: self.$truckRouteSearchOptions.axleLoad
		)
	}

	@ViewBuilder
	private func makeTruckPassIdPicker() -> some View {
		self.makeOptionTitle("Identifiers of the user's passes required for movement within the access zones.")
		ForEach(Array(self.truckRouteSearchOptions.passIds), id: \.self) { id in
			HStack {
				Text("\(id.value)")
				Spacer()
				Image(systemName: "clear")
				.frame(width: 30, height: 30)
				.foregroundColor(.red)
				.onTapGesture {
					self.truckRouteSearchOptions.passIds.remove(id)
				}
			}
			.frame(height: 40)
		}
		HStack {
			Text("Add pass")
			Image(systemName: "plus.circle")
			.frame(width: 30, height: 30)
			.foregroundColor(.green)
			.onTapGesture {
				self.createNewPassId()
			}
		}
		.frame(height: 40)
	}

	private func makeTaxiRouteSearchOptionsView() -> some View {
		VStack(alignment: .leading) {
			self.makeSectionTitle("Taxi:")
			self.makeCarRouteSearchOptionsContent(
				avoidTollRoads: self.$taxiRouteSearchOptions.car.avoidTollRoads,
				avoidUnpavedRoads: self.$taxiRouteSearchOptions.car.avoidUnpavedRoads,
				avoidFerry: self.$taxiRouteSearchOptions.car.avoidFerries,
				routeSearchType: self.$taxiRouteSearchOptions.car.routeSearchType
			)
		}
	}

	private func makeBicycleRouteSearchOptionsView() -> some View {
		VStack(alignment: .leading) {
			self.makeSectionTitle("Bicycle:")
			Toggle(isOn: self.$bicycleRouteSearchOptions.avoidCarRoads, label: {
				self.makeOptionTitle("Avoid car roads")
			})
			Toggle(isOn: self.$bicycleRouteSearchOptions.avoidStairways, label: {
				self.makeOptionTitle("Avoid stairways")
			})
			Toggle(isOn: self.$bicycleRouteSearchOptions.avoidUnderpassesAndOverpasses, label: {
				self.makeOptionTitle("Avoid underpasses and overpasses")
			})
		}
	}

	private func makeSectionTitle(_ text: String) -> some View {
		Text(text)
		.font(.system(size: 20))
		.fontWeight(.bold)
		.foregroundColor(.primaryTitle)
	}

	private func makeOptionTitle(_ text: String) -> some View {
		Text(text)
		.fontWeight(.bold)
		.foregroundColor(.primaryTitle)
		.fixedSize(horizontal: false, vertical: true)
	}

	private func createNewPassId() {
		guard let presenter = UIApplication.shared.keyWindow?.topViewController else { return }
		let alert = UIAlertController(title: "Add new pass", message: nil, preferredStyle: .alert)
		var textField: UITextField?
		alert.addTextField { field in
			field.keyboardType = .numberPad
			field.clearButtonMode = .whileEditing
			textField = field
		}
		alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { action in
			if let rawValue = textField?.text,
			   let value = UInt32(rawValue) {
				self.truckRouteSearchOptions.passIds.insert(.init(value: value))
			}
		}))
		alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
		presenter.present(alert, animated: true, completion: nil)
	}

}

extension TransportType: PickerViewOption {
	var id: Self {
		self
	}
}

extension RouteSearchType: PickerViewOption {
	public var id: RouteSearchType {
		self
	}

	var name: String {
		switch self {
			case .jam:
				return "Jam"
			case .shortest:
				return "Shortest"
			case .statistic:
				return "Statistic"
			@unknown default:
				assertionFailure("Unknown type: \(self)")
				return "Unknown \(self.rawValue)"
		}
	}

	static var availableTypes: [RouteSearchType] {
		[.jam, .shortest, .statistic]
	}
}

extension TruckPassZoneId: Identifiable {
	public var id: TruckPassZoneId {
		self
	}
}

extension PublicTransportTypeOptionSet: Identifiable {
	public var id: PublicTransportTypeOptionSet {
		self
	}

	fileprivate static var availableTypes: [PublicTransportTypeOptionSet] {
		[
			.bus, .trolleybus, .tram, .shuttleBus, .metro, .suburbanTrain,
			.funicularRailway, .monorail, .waterwayTransport, .cableCar, .speedTram,
			.premetro, .lightMetro, .aeroexpress, .moscowCentralRing, .moscowCentralDiameters
		]
	}

	fileprivate var name: String {
		var names: [String] = []
		if self.contains(.bus) {
			names.append("Bus")
		}
		if self.contains(.trolleybus) {
			names.append("Trolleybus")
		}
		if self.contains(.tram) {
			names.append("Tram")
		}
		if self.contains(.shuttleBus) {
			names.append("Shuttle bus")
		}
		if self.contains(.metro) {
			names.append("Metro")
		}
		if self.contains(.suburbanTrain) {
			names.append("Suburban train")
		}
		if self.contains(.funicularRailway) {
			names.append("Funicular railway")
		}
		if self.contains(.monorail) {
			names.append("Monorail")
		}
		if self.contains(.waterwayTransport) {
			names.append("Waterway transport")
		}
		if self.contains(.cableCar) {
			names.append("Cable car")
		}
		if self.contains(.speedTram) {
			names.append("Speed tram")
		}
		if self.contains(.premetro) {
			names.append("Premetro")
		}
		if self.contains(.lightMetro) {
			names.append("Light metro")
		}
		if self.contains(.aeroexpress) {
			names.append("Aeroexpress")
		}
		if self.contains(.moscowCentralRing) {
			names.append("Moscow central ring")
		}
		if self.contains(.moscowCentralDiameters) {
			names.append("Moscow central diameters")
		}
		return names.joined(separator: ", ")
	}
}
