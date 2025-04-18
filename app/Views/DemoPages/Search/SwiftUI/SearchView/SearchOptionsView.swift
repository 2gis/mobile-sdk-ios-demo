import SwiftUI
import DGis

struct SearchOptionsView: View {
	private enum Constants {
		static let titleFont: Font = .system(size: 20, weight: .bold)
	}

	@SwiftUI.State private var weekTime: WeekTime
	@SwiftUI.State private var searchOptions: SearchOptions
	@SwiftUI.State private var directoryFilterType: DirectoryFilterType
	@Binding private var isPresented: Bool
	private let onDidSaveOptions: (SearchOptions) -> Void

	init(
		searchOptions: SearchOptions,
		isPresented: Binding<Bool>,
		onDidSaveOptions: @escaping (SearchOptions) -> Void
	) {
		self._searchOptions = SwiftUI.State(initialValue: searchOptions)
		self._isPresented = isPresented
		self._directoryFilterType = SwiftUI.State(initialValue: searchOptions.directoryFilterType)
		self._weekTime = SwiftUI.State(initialValue: searchOptions.filter.directoryFilter?.weekTime ?? Date().weekTime)
		self.onDidSaveOptions = onDidSaveOptions
	}

	var body: some View {
		NavigationView {
			ScrollView {
				VStack(alignment: .leading) {
					PickerView(
						title: "Тип сортировки",
						titleFont: Constants.titleFont,
						selection: self.$searchOptions.sortingType,
						options: SortingType.availableTypes,
						pickerStyle: .segmented
					)
					.padding(.bottom)

					self.makeTitle("Количество элементов на странице результатов")
					HStack {
						Text("\(self.searchOptions.pageSize)")
						Slider(
							value: Binding<Double>(
								get: {
									Double(self.searchOptions.pageSize)
								}, set: {
									self.searchOptions.pageSize = Int32($0)
								}
							),
							in: Double(self.searchOptions.minPageSize)...Double(self.searchOptions.maxPageSize),
							step: 1
						)
					}
					.padding(.bottom)

					PickerView(
						title: "Фильтры для справочника",
						titleFont: Constants.titleFont,
						selection: Binding<DirectoryFilterType>(
							get: {
								self.directoryFilterType
							},
							set: {
								self.directoryFilterType = $0
								switch $0 {
									case .none:
										self.searchOptions.filter.directoryFilter = nil
									case .isOpenNow:
										self.searchOptions.filter.directoryFilter = .init(workTime: .isOpenNow(.init()), dynamic: [])
									case .workTime:
										self.searchOptions.filter.directoryFilter = .init(workTime: .workTime(self.weekTime), dynamic: [])
								}
							}
						),
						options: DirectoryFilterType.allCases,
						pickerStyle: .segmented
					)
					if self.directoryFilterType == .workTime {
						WeekTimePickerView(weekTime: Binding<WeekTime>(
							get: {
								self.weekTime
							},
							set: {
								self.weekTime = $0
								if case .workTime(_) = self.searchOptions.filter.directoryFilter?.workTime {
									self.searchOptions.filter.directoryFilter = .init(workTime: .workTime(self.weekTime), dynamic: [])
								}
							}
						))
					}

					self.makeTitle("Типы объектов, разрешенные в результате запроса")
					MultiSelectionPickerView(
						selection: self.$searchOptions.filter.allowedResultTypes,
						options: ObjectType.availableTypes
					)
					.padding(.top, 5)
				}
				.padding()
			}
			.navigationBarTitle("Настройки поиска", displayMode: .inline)
			.navigationBarItems(
				leading: Button("Отмена", action: { self.isPresented = false }),
				trailing: Button("Сохранить", action: {
					self.onDidSaveOptions(self.searchOptions)
					self.isPresented = false
				})
			)
		}
	}

	private func makeTitle(_ text: String) -> Text {
		Text(text).font(Constants.titleFont)
	}
}

private enum DirectoryFilterType: CaseIterable {
	case none
	case isOpenNow
	case workTime
}

extension DirectoryFilterType: PickerViewOption {
	var id: DirectoryFilterType {
		self
	}

	var name: String {
		switch self {
			case .none:
				return "Без фильтра"
			case .isOpenNow:
				return "Открыто сейчас"
			case .workTime:
				return "Время работы объекта"
		}
	}
}

private extension SearchOptions {
	var directoryFilterType: DirectoryFilterType {
		if let filter = self.filter.directoryFilter, let workTime = filter.workTime {
			switch workTime {
				case .isOpenNow:
					return .isOpenNow
				case .workTime:
					return .workTime
				@unknown default:
					fatalError("Unsupported WorkTimeFilter: \(self)")
			}
		} else {
			return .none
		}
	}
}

extension SortingType: PickerViewOption {
	public var id: SortingType { self }

	var name: String {
		switch self {
			case .byRelevance:
				return "По релевантности"
			case .byDistance:
				return "По расстоянию"
			case .byRating:
				return "По рейтингу"
			@unknown default:
				assertionFailure("Unsupported SortingType: \(self)")
				return "Неизвестный тип"
		}
	}

	static let availableTypes: [SortingType] = [.byRelevance, .byDistance, .byRating]
}

extension ObjectType: PickerViewOption {
	public var id: ObjectType { self }

	static let defaultTypes: [ObjectType] = {
		var types = availableTypes
		if let index = types.firstIndex(of: .road) {
			types.remove(at: index)
		}
		return types
	}()

	fileprivate static let availableTypes: [ObjectType] = [
		.admDiv,
		.attraction,
		.branch,
		.building,
		.coordinates,
		.crossroad,
		.parking,
		.road,
		.route,
		.station,
		.stationEntrance,
		.street,
		.unknown
	]
}

private extension DirectoryFilter {
	var weekTime: WeekTime? {
		guard let workTimeFilter = self.workTime else { return nil }
		switch workTimeFilter {
			case .workTime(let weekTime):
				return weekTime
			default:
				return nil
		}
	}
}
