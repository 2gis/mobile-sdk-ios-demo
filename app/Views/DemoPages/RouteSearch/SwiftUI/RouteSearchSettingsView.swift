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
			.navigationBarTitle(Text("Настройки"), displayMode: .inline)
			.navigationBarItems(
				trailing: Button("Закрыть", action: {
					self.shown = false
				})
			)
		}
	}

	private func makeTransportTypePicker() -> some View {
		PickerView(
			title: "Тип транспорта:",
			selection: self.$transportType,
			options: TransportType.allCases,
			pickerStyle: WheelPickerStyle()
		)
	}

	private func makeCarRouteSearchOptionsView() -> some View {
		VStack(alignment: .leading) {
			self.makeSectionTitle("Авто:")
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
			self.makeOptionTitle("Избегать платные дороги")
		})
		Toggle(isOn: avoidUnpavedRoads, label: {
			self.makeOptionTitle("Избегать грунтовые дороги")
		})
		Toggle(isOn: avoidFerry, label: {
			self.makeOptionTitle("Избегать паромные переправы")
		})
		PickerView(
			title: "Тип поиска маршрута",
			selection: routeSearchType,
			options: RouteSearchType.availableTypes,
			pickerStyle: SegmentedPickerStyle()
		)
	}

	private func makePublicTransportRouteSearchOptionsView() -> some View {
		VStack(alignment: .leading) {
			self.makeSectionTitle("Общественный транспорт:")
			Toggle(isOn: self.$publicTransportRouteSearchOptions.useSchedule, label: {
				self.makeOptionTitle("Учитывать расписания")
			})
			RouteSearchSettingsDatePicker(
				title: "Время в UTC, на которое нужно построить маршрут.",
				subtitle: "Если не задано, используется текущее время",
				date: self.$publicTransportRouteSearchOptions.startTime
			)
			self.makePublicTransportTypePicker()
			.padding(.top, 10)
		}
	}

	@ViewBuilder
	private func makePublicTransportTypePicker() -> some View {
		self.makeOptionTitle("Типы общественного транспорта")
		Text("Если не заполнены, маршруты будут строиться для всех поддерживаемых типов общественного транспорта.")
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
			self.makeSectionTitle("Грузовики:")
			Toggle(isOn: self.$truckRouteSearchOptions.dangerousCargo, label: {
				self.makeOptionTitle("Признак наличия опасного груза")
			})
			Toggle(isOn: self.$truckRouteSearchOptions.explosiveCargo, label: {
				self.makeOptionTitle("Признак наличия взрывчатых веществ в грузе")
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
			title: "Длина грузового транспортного средства в миллиметрах",
			value: self.$truckRouteSearchOptions.truckLength
		)
		SettingsFormTextField(
			title: "Высота грузового транспортного средства в миллиметрах",
			value: self.$truckRouteSearchOptions.truckHeight
		)
		SettingsFormTextField(
			title: "Ширина грузового транспортного средства в миллиметрах",
			value: self.$truckRouteSearchOptions.truckWidth
		)
		SettingsFormTextField(
			title: "Фактическая масса грузового транспортного средства в килограммах",
			value: self.$truckRouteSearchOptions.actualMass
		)
		SettingsFormTextField(
			title: "Разрешённая максимальная масса грузового транспортного средства в килограммах",
			value: self.$truckRouteSearchOptions.maxPermittedMass
		)
		SettingsFormTextField(
			title: "Нагрузка на ось в килограммах",
			value: self.$truckRouteSearchOptions.axleLoad
		)
	}

	@ViewBuilder
	private func makeTruckPassIdPicker() -> some View {
		self.makeOptionTitle("Идентификаторы имеющихся у пользователя пропусков, требующихся для движения в пределах пропускных зон")
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
			Text("Добавить пропуск")
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
			self.makeSectionTitle("Такси:")
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
			self.makeSectionTitle("Велосипед:")
			Toggle(isOn: self.$bicycleRouteSearchOptions.avoidCarRoads, label: {
				self.makeOptionTitle("Избегать автомобильные дороги")
			})
			Toggle(isOn: self.$bicycleRouteSearchOptions.avoidStairways, label: {
				self.makeOptionTitle("Избегать лестницы")
			})
			Toggle(isOn: self.$bicycleRouteSearchOptions.avoidUnderpassesAndOverpasses, label: {
				self.makeOptionTitle("Избегать подземных и надземных переходов")
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
		let alert = UIAlertController(title: "Новый пропуск", message: nil, preferredStyle: .alert)
		var textField: UITextField?
		alert.addTextField { field in
			field.keyboardType = .numberPad
			field.clearButtonMode = .whileEditing
			textField = field
		}
		alert.addAction(UIAlertAction(title: "Добавить", style: .default, handler: { action in
			if let rawValue = textField?.text,
			   let value = UInt32(rawValue) {
				self.truckRouteSearchOptions.passIds.insert(.init(value: value))
			}
		}))
		alert.addAction(UIAlertAction(title: "Отмена", style: .cancel, handler: nil))
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
			names.append("Автобус")
		}
		if self.contains(.trolleybus) {
			names.append("Троллейбус")
		}
		if self.contains(.tram) {
			names.append("Трамвай")
		}
		if self.contains(.shuttleBus) {
			names.append("Маршрутное такси")
		}
		if self.contains(.metro) {
			names.append("Метро")
		}
		if self.contains(.suburbanTrain) {
			names.append("Электропоезд")
		}
		if self.contains(.funicularRailway) {
			names.append("Фуникулёр")
		}
		if self.contains(.monorail) {
			names.append("Монорельс")
		}
		if self.contains(.waterwayTransport) {
			names.append("Водный транспорт")
		}
		if self.contains(.cableCar) {
			names.append("Канатная дорога")
		}
		if self.contains(.speedTram) {
			names.append("Скоростной трамвай")
		}
		if self.contains(.premetro) {
			names.append("Подземный трамвай")
		}
		if self.contains(.lightMetro) {
			names.append("Лёгкое метро")
		}
		if self.contains(.aeroexpress) {
			names.append("Аэроэкспресс")
		}
		if self.contains(.moscowCentralRing) {
			names.append("Московское центральное кольцо")
		}
		if self.contains(.moscowCentralDiameters) {
			names.append("Московские центральные диаметры")
		}
		return names.joined(separator: ", ")
	}
}
