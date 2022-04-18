## Начало работы

Для работы с SDK нужно создать специальный объект [Container](/ru/ios/sdk/reference/2.0/Container), который будет хранить все сущности, связанные с картой.

Чтобы его создать, нужно указать набор ключей доступа к SDK в виде структуры [APIKeys](/ru/ios/sdk/reference/2.0/APIKeys).

```swift
// Набор ключей для доступа к сервисам.
guard let apiKeys = APIKeys(directory: "Directory API key", map: "SDK key") else { 
	fatalError("Указанные API-ключи недействительны.") 
}

// Создание контейнера для доступа к возможностям SDK.
let sdk = DGis.Container(apiKeys: apiKeys)
```

Дополнительно можно указать настройки журналирования ([LogOptions](/ru/ios/sdk/reference/2.0/LogOptions)) и настройки HTTP-клиента ([HTTPOptions](/ru/ios/sdk/reference/2.0/HTTPOptions)), такие как время ожидания ответа и кеширование.

```swift
// Настройки журналирования.
let logOptions = LogOptions(osLogLevel: .info)

// Настройки HTTP-клиента.
let httpOptions = HTTPOptions(timeout: 5, cacheOptions: nil)

// Сервисы геопозиционирования.
let positioningServices: IPositioningServicesFactory = CustomPositioningServicesFactory()

// Настройки сбора анонимной статистики использования.
let dataCollectionOptions = DataCollectionOptions(dataCollectionStatus: .agree)

// Создание контейнера.
let sdk = DGis.Container(
	apiKeys: apiKeys,
	logOptions: logOptions,
	httpOptions: httpOptions,
	positioningServices: positioningServices,
	dataCollectionOptions: dataCollectionOptions
)
```

## Создание карты

Чтобы создать карту, нужно вызвать метод [makeMapFactory()](/ru/ios/sdk/reference/2.0/Container#nav-lvl1--makeMapFactory) и передать настройки карты в виде структуры [MapOptions](/ru/ios/sdk/reference/2.0/MapOptions).

В настройках важно указать корректное для устройства значение PPI. Его можно найти в [спецификации устройства](https://support.apple.com/specs).

Кроме этого в настройках можно указать начальную позицию камеры, границы масштабирования и другие параметры.

```swift
// Настройки карты.
var mapOptions = MapOptions.default

// Значение PPI для устройства.
mapOptions.devicePPI = devicePPI

// Создание фабрики объектов карты.
let mapFactory: PlatformMapSDK.IMapFactory = sdk.makeMapFactory(options: mapOptions)
```

Получить слой карты можно через свойство `mapView`. Контроллер карты доступен через свойство `map` (см. класс [Map](/ru/ios/sdk/reference/2.0/Map)).

```swift
// Слой карты.
let mapView: UIView & IMapView = mapFactory.mapView

// Контроллер карты.
let map = mapFactory.map
```

## Общие принципы работы

### Работа с отложенными результатами

Некоторые методы SDK (например те, которые обращаются к удаленному серверу) возвращают отложенные результаты (объект [Future](/ru/ios/sdk/reference/2.0/Future)). Для работы с ними нужно создать обработчик получения данных и обработчик ошибок. Обработать результат в главной очереди можно с помощью [DispatchQueue](https://developer.apple.com/documentation/dispatch/dispatchqueue).

Пример получения объекта из справочника:

```swift
// Создание объекта для поиска по справочнику.
let searchManager = SearchManager.createOnlineManager(context: sdk.context)

// Получение объекта из справочника по идентификатору.
let future = searchManager.searchByDirectoryObjectId(objectId: object.id)

// Обработка результата поиска в главной очереди.
// Сохраняем результат вызова, так как его удаление отменяет обработку.
self.searchDirectoryObjectCancellable = future.sink(
	receiveValue: {
		[weak self] directoryObject in
		guard let directoryObject = directoryObject else { return }
		DispatchQueue.main.async {
			self.handle(directoryObject)
		}
	},
	failure: { error in
		DispatchQueue.main.async {
			self.handle(error)
		}
	}
)
```

Для упрощения работы можно создать расширение:

```swift
extension DGis.Future {
	func sinkOnMainThread(
		receiveValue: @escaping (Value) -> Void,
		failure: @escaping (Error) -> Void
	) -> DGis.Cancellable {
		self.sink(on: .main, receiveValue: receiveValue, failure: failure)
	}

	func sink(
		on queue: DispatchQueue,
		receiveValue: @escaping (Value) -> Void,
		failure: @escaping (Error) -> Void
	) -> DGis.Cancellable {
		self.sink { value in
			queue.async {
				receiveValue(value)
			}
		} failure: { error in
			queue.async {
				failure(error)
			}
		}
	}
}

self.searchDirectoryObjectCancellable = future.sinkOnMainThread(
	receiveValue: {
		[weak self] directoryObject in
		guard let directoryObject = directoryObject else { return }
		self.handle(directoryObject)
	},
	failure: { error in
		self.handle(error)
	}
)
```

Можно также использовать [Combine](https://developer.apple.com/documentation/combine):

```swift
// Создание Combine.Future из DGis.Future.
extension DGis.Future {
	func asCombineFuture() -> Combine.Future<Value, Error> {
		Combine.Future { [self] promise in
			// Удерживаем ссылку на Cancellable, пока не будет вызван обработчик
			// Combine.Future не позволяет конфигурировать отмену напрямую
			var cancellable: DGis.Cancellable?
			cancellable = self.sink {
				promise(.success($0))
				_ = cancellable
			} failure: {
				promise(.failure($0))
				_ = cancellable
			}
		}
	}
}

// Создание Combine.Future.
let combineFuture = future.asCombineFuture()

// Обработка результата поиска в главной очереди.
combineFuture.receive(on: DispatchQueue.main).sink {
	[weak self] completion in
	switch completion {
		case .failure(let error):
			self?.handle(error)
		case .finished:
			break
	}
} receiveValue: {
	[weak self] directoryObject in
	self?.handle(directoryObject)
}.store(in: &self.subscriptions)
```

### Работа с потоками значений

Некоторые объекты SDK предоставляют потоки значений, которые можно обработать, используя механизм каналов: на поток можно подписаться, указав функцию-обработчик данных, и отписаться, когда обработка данных больше не требуется. Для работы с потоками значений используется класс [Channel](/ru/ios/sdk/reference/2.0/Channel).

Пример подписки на изменение видимой области карты (поток новых прямоугольных областей):

```swift
// Выбираем канал (прямоугольники видимой области карты).
let visibleRectChannel = map.camera.visibleRectChannel

// Подписываемся и обрабатываем результаты в главной очереди. Значения будут присылаться при любом изменении видимой области до момента отписки.
// Важно сохранить Cancellable, иначе подписка будет уничтожена.
self.cancellable = visibleRectChannel.sink { [weak self] visibleRect in
	DispatchQueue.main.async {
		self?.handle(visibleRect)
	}
}
```

Чтобы отменить подписку, нужно вызвать метод `cancel()`:

```swift
self.cancellable.cancel()
```

Для упрощения работы можно создать расширение:

```swift
extension Channel {
	func sinkOnMainThread(receiveValue: @escaping (Value) -> Void) -> DGis.Cancellable {
		self.sink(on: .main, receiveValue: receiveValue)
	}

	func sink(on queue: DispatchQueue, receiveValue: @escaping (Value) -> Void) -> DGis.Cancellable {
		self.sink { value in
			queue.async {
				receiveValue(value)
			}
		}
	}
}

self.cancellable = visibleRectChannel.sinkOnMainThread { [weak self] visibleRect in
	self?.handle(visibleRect)
}
```

## Добавление объектов

Для добавления динамических объектов на карту (маркеров, линий, кругов, многоугольников) нужно создать менеджер объектов ([MapObjectManager](/ru/ios/sdk/reference/2.0/MapObjectManager)), указав инстанс карты.

```swift
// Сохраняем объект в свойство, так как при удалении менеджера исчезают все связанные с ним объекты на карте.
self.objectManager = MapObjectManager(map: map)
```

Для добавления объектов используются методы [addObject()](/ru/ios/sdk/reference/2.0/MapObjectManager#nav-lvl1--addObject) и [addObjects()](/ru/ios/sdk/reference/2.0/MapObjectManager#nav-lvl1--addObjects). Для каждого динамического объекта можно указать поле `userData`, которое будет хранить произвольные данные, связанные с объектом. Настройки объектов можно менять после их создания.

Для удаления объектов используются методы [removeObject()](/ru/ios/sdk/reference/2.0/MapObjectManager#nav-lvl1--removeObject) и [removeObjects()](/ru/ios/sdk/reference/2.0/MapObjectManager#nav-lvl1--removeObjects). Чтобы удалить все объекты, можно использовать метод [removeAll()](/ru/ios/sdk/reference/2.0/MapObjectManager#nav-lvl1--removeAll).

### Маркер

Чтобы добавить маркер на карту, нужно создать объект [Marker](/ru/ios/sdk/reference/2.0/Marker), указав нужные настройки ([MarkerOptions](/ru/ios/sdk/reference/2.0/MarkerOptions)), и передать его в вызов `addObject()` менеджера объектов.

Иконку для маркера можно создать с помощью метода `make()` фабрики изображений ([IImageFactory](/ru/ios/sdk/reference/2.0/IImageFactory)), используя [UIImage](https://developer.apple.com/documentation/uikit/uiimage), PNG-данные или SVG-разметку.

```swift
// Иконка на основе UIImage.
let uiImage = UIImage(systemName: "umbrella.fill")!.withTintColor(.systemRed)
let icon = sdk.imageFactory.make(image: uiImage)

// Иконка на основе SVG-данных.
let icon = sdk.imageFactory.make(svgData: imageData, size: imageSize)

// Иконка на основе PNG-данных (быстрее, чем из UIImage).
let icon = sdk.imageFactory.make(pngData: imageData, size: imageSize)

// Настройки маркера.
let options = MarkerOptions(
	position: GeoPointWithElevation(
		latitude: 55.752425,
		longitude: 37.613983
	),
	icon: icon
)

// Создание и добавление маркера.
let marker = Marker(options: options)
objectManager.addObject(object: marker)
```

Чтобы изменить точку привязки иконки (выравнивание иконки относительно координат на карте), нужно указать параметр [anchor](/ru/ios/sdk/reference/2.0/Anchor).

### Линия

Чтобы нарисовать на карте линию, нужно создать объект [Polyline](/ru/ios/sdk/reference/2.0/Polyline), указав нужные настройки, и передать его в вызов `addObject()` менеджера объектов.

Кроме массива координат для точек линии, в настройках можно указать ширину линии, цвет, пунктир, обводку и другие параметры (см. [PolylineOptions](/ru/ios/sdk/reference/2.0/PolylineOptions)).

```swift
// Координаты вершин ломаной линии.
let points = [
	GeoPoint(latitude: 55.7513, longitude: value: 37.6236),
	GeoPoint(latitude: 55.7405, longitude: value: 37.6235),
	GeoPoint(latitude: 55.7439, longitude: value: 37.6506)
]

// Настройки линии.
let options = PolylineOptions(
	points: points,
	width: LogicalPixel(value: 2),
	color: DGis.Color.init()
)

// Создание и добавление линии.
let polyline = Polyline(options: options)
objectManager.addObject(object: polyline)
```

### Многоугольник

Чтобы нарисовать на карте многоугольник, нужно создать объект [Polygon](/ru/sdk/reference/2.0/Polygon), указав нужные настройки, и передать его в вызов `addObject()` менеджера объектов.

Координаты для многоугольника указываются в виде двумерного массива. Первый вложенный массив должен содержать координаты основных вершин многоугольника. Остальные вложенные массивы не обязательны и могут быть заданы для того, чтобы создать вырез внутри многоугольника (один дополнительный массив - один вырез в виде многоугольника).

Дополнительно можно указать цвет полигона и параметры обводки (см. [PolygonOptions](/ru/sdk/reference/2.0/PolygonOptions)).

```swift
// Настройки многоугольника.
let options = PolygonOptions(
	contours: [
		// Вершины многоугольника.
		[
			GeoPoint(latitude: 55.72014932919687, longitude: 37.562599182128906),
			GeoPoint(latitude: 55.72014932919687, longitude: 37.67555236816406),
			GeoPoint(latitude: 55.78004852149085, longitude: 37.67555236816406),
			GeoPoint(latitude: 55.78004852149085, longitude: 37.562599182128906),
			GeoPoint(latitude: 55.72014932919687, longitude: 37.562599182128906)
		],
		// Координаты выреза внутри многоугольника.
		[
			GeoPoint(latitude: 55.754167897761, longitude: 37.62422561645508),
			GeoPoint(latitude: 55.74450654680055, longitude: 37.61238098144531),
			GeoPoint(latitude: 55.74460317215391, longitude: 37.63435363769531),
			GeoPoint(latitude: 55.754167897761, longitude: 37.62422561645508)
		]
	],
	color: DGis.Color.init(),
	strokeWidth: LogicalPixel(value: 2)
)

// Создание и добавление многоугольника.
let polygon = Polygon(options: options)
objectManager.addObject(object: polygon)
```

### Кластеризация

Для добавления маркеров на карту в режиме кластеризации нужно создать менеджер объектов ([MapObjectManager](/ru/ios/sdk/reference/2.0/MapObjectManager)) через [MapObjectManager.withClustering()](/ru/ios/sdk/reference/2.0/MapObjectManager#nav-lvl1--withClustering), указав инстанс карты, расстояние между кластерами в логических пикселях, максимальный zoom-уровень формирования кластеров и пользовательскую имплементацию протокола SimpleClusterRenderer.
[SimpleClusterRenderer](/ru/ios/sdk/reference/2.0/SimpleClusterRenderer) используется для кастомизации кластеров в [MapObjectManager](/ru/ios/sdk/reference/2.0/MapObjectManager).

```swift
final class SimpleClusterRendererImpl: SimpleClusterRenderer {
	private let image: DGis.Image
	private var idx = 0

	init(
		image: DGis.Image
	) {
		self.image = image
	}

	func renderCluster(cluster: SimpleClusterObject) -> SimpleClusterOptions {
		let textStyle = TextStyle(
			fontSize: LogicalPixel(15.0),
			textPlacement: TextPlacement.rightTop
		)
		let objectCount = cluster.objectCount
		let iconMapDirection = objectCount < 5 ? MapDirection(value: 45.0) : nil
		idx += 1
		return SimpleClusterOptions(
			icon: self.image,
			iconMapDirection: iconMapDirection,
			text: String(objectCount),
			textStyle: textStyle,
			iconWidth: LogicalPixel(30.0),
			userData: idx,
			zIndex: ZIndex(value: 6),
			animatedAppearance: false
		)
	}
}

self.objectManager = MapObjectManager.withClustering(
	map: map,
	logicalPixel: LogicalPixel(80.0),
	maxZoom: Zoom(19.0),
	clusterRenderer: SimpleClusterRendererImpl(image: self.icon)
)
```

## Управление камерой

Для работы с камерой используется объект [Camera](/ru/ios/sdk/reference/2.0/Camera), доступный через свойство `map.camera`.

### Перелёт

Чтобы запустить анимацию перелёта камеры, нужно вызвать метод [move()](/ru/ios/sdk/reference/2.0/Camera#nav-lvl1--move) и указать параметры перелёта:

- `position` - конечная позиция камеры (координаты и уровень приближения). Дополнительно можно указать наклон и поворот камеры (см. [CameraPosition](/ru/ios/sdk/reference/2.0/CameraPosition)).
- `time` - продолжительность перелёта в секундах ([TimeInterval](https://developer.apple.com/documentation/foundation/timeinterval)).
- `animationType` - тип анимации ([CameraAnimationType](/ru/ios/sdk/reference/2.0/CameraAnimationType)).

Функция `move()` возвращает объект [Future](/ru/ios/sdk/reference/2.0/Future), который можно использовать, чтобы обработать событие завершения перелета.

```swift
// Новая позиция камеры.
let newCameraPosition = CameraPosition(
	point: GeoPoint(latitude: 55.752425, longitude: 37.613983),
	zoom: Zoom(value: 16)
)

// Запуск перелёта.
let future = map.camera.move(
	position: newCameraPosition,
	time: 0.4,
	animationType: .linear
)

// Получение события завершения перелета.
let cancellable = future.sink { _ in
	print("Перелет камеры завершён.")
} failure: { error in
	print("Возникла ошибка: \(error.localizedDescription)")
}
```

### Получение состояния камеры

Текущее состояние камеры (находится ли камера в полёте) можно получить, используя свойство `state`. См. [CameraState](/ru/ios/sdk/reference/2.0/CameraState) для списка возможных состояний камеры.

```swift
let currentState = map.camera.state
```

Подписаться на изменения состояния камеры можно, используя `stateChannel.sink`.

```swift
// Подписка.
let connection = map.camera.stateChannel.sink { state in
	print("Состояние камеры изменилось на \(state)")
}

// Отписка.
connection.cancel()
```

### Получение позиции камеры

Текущую позицию камеры можно получить, используя свойство `position` (см. структуру [CameraPosition](/ru/ios/sdk/reference/2.0/CameraPosition)).

```swift
let currentPosition = map.camera.position
print("Координаты: \(currentPosition.point)")
print("Приближение: \(currentPosition.zoom)")
print("Наклон: \(currentPosition.tilt)")
print("Поворот: \(currentPosition.bearing)")
```

Подписаться на изменения позиции камеры (и угла наклона/поворота) можно, используя `positionChannel.sink`.

```swift
// Подписка.
let connection = map.camera.positionChannel.sink { position in
	print("Изменилась позиция камеры или угол наклона/поворота.")
}

// Отписка.
connection.cancel()
```

## Моё местоположение

На карту можно добавить специальный маркер, который будет отражать текущее местоположение устройства. Для этого нужно создать источник данных, вызвав [createMyLocationMapObjectSource()](/ru/ios/sdk/reference/2.0/createMyLocationMapObjectSource(context%3AdirectionBehaviour%3A)) и указав контейнер объектов SDK (`sdk.context`). Созданный источник нужно передать в метод карты [addSource()](/ru/ios/sdk/reference/2.0/Map#nav-lvl1--addSource).

```swift
// Создание источника данных.
let source = createMyLocationMapObjectSource(
	context: sdk.context,
	directionBehaviour: MyLocationDirectionBehaviour.followMagneticHeading
)

// Добавление маркера на карту.
map.addSource(source: source)
```

Чтобы удалить маркер, нужно вызвать метод [removeSource()](/ru/ios/sdk/reference/2.0/Map#nav-lvl1--removeSource). Список активных источников данных можно получить, используя свойство `map.sources`.

```swift
map.removeSource(source)
```

## Навигатор

Чтобы создать навигатор, можно использовать готовый элемент интерфейса [INavigationView](/ru/ios/sdk/reference/2.2/INavigationView) и класс [NavigationManager](/ru/ios/sdk/reference/2.2/NavigationManager).

Для этого нужно добавить на карту маркер с текущим местоположением и создать слой навигатора с помощью фабрики [INavigationViewFactory](/ru/ios/sdk/reference/2.2/INavigationViewFactory) и класса [NavigationManager](/ru/ios/sdk/reference/2.2/NavigationManager).

```swift
// Создаём фабрику объектов карты.
guard let mapFactory = try? sdk.makeMapFactory(options: .default) else {
    return
}

// Добавляем слой карты в иерархию представлений.
let mapView = mapFactory.mapView
mapView.translatesAutoresizingMaskIntoConstraints = false
containerView.addSubview(mapView)
NSLayoutConstraint.activate([
    mapView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
    mapView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
    mapView.topAnchor.constraint(equalTo: containerView.topAnchor),
    mapView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
])

// Добавляем на карту маркер с текущим местоположением.
let locationSource = MyLocationMapObjectSource(
    context: sdk.context,
    directionBehaviour: .followSatelliteHeading,
    controller: createSmoothMyLocationController()
)
let map = mapFactory.map
map.addSource(source: locationSource)

// Создаём NavigationManager.
let navigationManager = NavigationManager(platformContext: sdk.context)

// Добавляем карту в навигатор.
navigationManager.mapManager.addMap(map: map)

// Создаём фабрику UI-компонентов навигатора.
let navigationViewFactory = sdk.makeNavigationViewFactory()

// Создаём с помощью фабрики слой навигатора и размещаем его в иерархии выше слоя карты.
let navigationView = navigationViewFactory.makeNavigationView(
    map: map,
    navigationManager: navigationManager
)
navigationView.translatesAutoresizingMaskIntoConstraints = false
containerView.addSubview(navigationView)
NSLayoutConstraint.activate([
    navigationView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
    navigationView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
    navigationView.topAnchor.constraint(equalTo: containerView.topAnchor),
    navigationView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
])

// Добавляем обработчик нажатия кнопки закрытия.
navigationView.closeButtonCallback = { [weak navigationManager] in
    navigationManager?.stop()
}
```

Навигатор может работать в трёх режимах: свободная навигация, ведение по маршруту и симуляция ведения.

Настройки навигатора можно изменить через [свойства NavigationManager](/ru/ios/sdk/reference/2.2/NavigationManager#nav-lvl1--uiModel).

### Свободная навигация

В этом режиме маршрут следования отсутствует, но навигатор будет информировать о превышениях скорости, дорожных камерах, авариях и ремонтных работах.

Чтобы запустить навигатор в этом режиме, нужно вызвать метод `start()` без параметров.

```swift
navigationManager.start()
```

### Ведение по маршруту

В этом режиме на карте будет построен маршрут от текущего местоположения до указанной точки назначения, и пользователь будет получать инструкции по мере движения.

Чтобы запустить навигатор в этом режиме, нужно вызвать метод `start()` и указать объект [RouteBuildOptions](/ru/ios/sdk/reference/2.2/RouteBuildOptions) - координаты точки назначения и настройки маршрута.

```swift
let routeBuildOptions = RouteBuildOptions(
    finishPoint: RouteSearchPoint(
        coordinates: GeoPoint(
            latitude: 55.752425,
            longitude: 37.613983
        )
    ),
    routeSearchOptions: routeSearchOptions
)

navigationManager.start(routeBuildOptions)
```

Дополнительно при вызове метода `start()` можно указать объект [TrafficRoute](/ru/ios/sdk/reference/2.2/TrafficRoute) - готовый маршрут для навигации. В таком случае навигатор не будет пытаться построить маршрут от текущего местоположения, а начнёт ведение по указанному маршруту.

```swift
// Ищем маршрут.
self.routeSearchCancellable = routesFuture.sink { routes in
    guard let route = routes.first else { return }

    // Настройки маршрута.
    let routeBuildOptions = RouteBuildOptions(
        finishPoint: finishPoint,
        routeSearchOptions: routeSearchOptions
    )
    // Запускаем навигатор.
    navigationManager.start(
        routeBuildOptions: routeBuildOptions,
        trafficRoute: route
    )
} failure: { error in
    print("Не удалось найти маршрут: \\(error)")
}
```

### Симуляция ведения по маршруту

В этом режиме навигатор не будет отслеживать реальное местоположение устройства, а запустит симулированное движение по указанному маршруту. Режим удобно использовать для отладки.

Чтобы запустить навигатор в режиме симуляции, нужно вызвать метод `startSimulation()`, указав готовый маршрут ([TrafficRoute](/ru/ios/sdk/reference/2.2/TrafficRoute)) и его настройки ([RouteBuildOptions](/ru/ios/sdk/reference/2.2/RouteBuildOptions)).

Скорость движения можно изменить с помощью свойства [SimulationSettings.speed](/ru/ios/sdk/reference/2.2/SimulationSettings) (метры в секунду).

```swift
navigationManager.simulationSettings.speed = 30 / 3.6
navigationManager.startSimulation(
    routeBuildOptions: routeBuildOptions,
    trafficRoute: route
)
```

Остановить симуляцию можно с помощью метода `stop()`.

```swift
navigationManager.stop()
```

## Получение объектов по экранным координатам

Информацию об объектах на карте можно получить, используя пиксельные координаты. Для этого нужно вызвать метод карты [getRenderedObjects()](/ru/ios/sdk/reference/2.0/Map#nav-lvl1--getRenderedObjects), указав координаты в пикселях и радиус в экранных миллиметрах. Метод вернет отложенный результат, содержащий информацию обо всех найденных объектах в указанном радиусе на видимой области карты (массив [RenderedObjectInfo](/ru/ios/sdk/reference/2.0/RenderedObjectInfo)).

Пример функции, которая принимает координаты нажатия на экран и передает их в метод `getRenderedObjects()`:

```swift
private func tap(point: ScreenPoint, tapRadius: ScreenDistance) {
	let cancel = map.getRenderedObjects(centerPoint: point, radius: tapRadius).sink(
		receiveValue: {
			infos in
			// Первый объект в массиве - самый близкий к координатам.
			guard let info = infos.first else { return }
			// Обработка результата в главной очереди.
			DispatchQueue.main.async {
				[weak self] in
				self?.handle(selectedObject: info)
			}
		},
		failure: { error in
			print("Ошибка получения информации об объектах: \(error)")
		}
	)
	// Сохраняем результат вызова, так как его удаление отменяет обработку.
	self.getRenderedObjectsCancellable = cancel
}
```

## Стили карты

Для работы со стилями нужно создать объект [IStyleFactory](/ru/ios/sdk/reference/2.0/IStyleFactory) с помощью метода [makeStyleFactory()](/ru/ios/sdk/reference/2.0/Container#nav-lvl1--makeStyleFactory).

```swift
let styleFactory = sdk.makeStyleFactory()
```

Чтобы создать стиль карты, совместимый с SDK, воспользуйтесь функцией «Экспорт» в [редакторе стилей](https://styles.2gis.com/) и добавьте скачанный файл в ваш проект.

### Создание карты с пользовательским стилем

Чтобы создать карту с произвольным стилем, нужно загрузить нужный стиль с помощью метода [loadResource()](/ru/ios/sdk/reference/2.0/IStyleFactory#nav-lvl1--loadResource) или [loadFile()](/ru/ios/sdk/reference/2.0/IStyleFactory#nav-lvl1--loadFile) фабрики стилей и указать получившийся объект в качестве параметра `styleFuture` в настройках карты.

```swift
// Создаём фабрику стилей.
let styleFactory = sdk.makeStyleFactory()

// Устанавливаем начальный стиль карты в настройках.
var mapOptions = MapOptions.default
mapOptions.styleFuture = styleFactory.loadResource(name: "custom_style_file.2gis", bundle: .main)

// Создаём карту с указанными настройками.
let mapFactory = sdk.makeMapFactory(options: mapOptions)
```

Методы [loadResource()](/ru/ios/sdk/reference/2.0/IStyleFactory#nav-lvl1--loadResource) и [loadFile()](/ru/ios/sdk/reference/2.0/IStyleFactory#nav-lvl1--loadFile) возвращают отложенное значение ([Future](/ru/ios/sdk/reference/2.0/Future)), чтобы не задерживать загрузку карты. Если стиль уже был загружен (см. следующий раздел), его можно превратить в объект [Future](/ru/ios/sdk/reference/2.0/Future) с помощью метода [makeReadyValue()](/ru/ios/sdk/reference/2.0/Future#nav-lvl1--makeReadyValue).

```swift
var mapOptions = MapOptions.default
mapOptions.styleFuture = Future.makeReadyValue(style)
```

### Изменение стиля карты

Изменить стиль существующей карты можно при помощи метода [setStyle()](/ru/ios/sdk/reference/2.0/Map#nav-lvl1--setStyle).

В отличие от указания стиля при создании карты, [setStyle()](/ru/ios/sdk/reference/2.0/Map#nav-lvl1--setStyle) принимает не [Future](/ru/ios/sdk/reference/2.0/Future), а загруженный стиль карты ([Style](/ru/ios/sdk/reference/2.0/Style)). Поэтому [setStyle()](/ru/ios/sdk/reference/2.0/Map#nav-lvl1--setStyle) следует вызывать после завершения загрузки [Future](/ru/ios/sdk/reference/2.0/Future).

```swift
// Создаём фабрику стилей.
let styleFactory = sdk.makeStyleFactory()

// Загружаем новый стиль карты. Метод loadFile() принимает только локальные URL (file://).
self.cancellable = styleFactory.loadFile(url: styleFileURL).sink(
	receiveValue: { [map = self.map] style in
		// Меняем стиль карты после загрузки.
		map.setStyle(style: style)
	},
	failure: { error in
		print("Не удалось загрузить стиль из файла <\(fileURL)>. Ошибка: \(error)")
	})
```

### Светлые и тёмные темы

Стили карты могут содержать несколько тем (например, дневную и ночную), между которыми можно переключаться без необходимости загрузки дополнительного стиля. Название используемой темы можно указать при создании карты с помощью параметра [appearance](/ru/ios/sdk/reference/2.0/MapOptions#nav-lvl1--appearance).

В iOS 13.0 и выше можно использовать автоматическое переключение между светлой и тёмной темами (см. [Dark Mode](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/dark-mode)).

```swift
// Настройки карты.
var mapOptions = MapOptions.default

// Название светлой темы в используемом стиле.
let lightTheme: Theme = "day"

// Название тёмной темы в используемом стиле.
let darkTheme: Theme = "night"

if #available(iOS 13.0, *) {
	// Автоматически переключаемся между темами в iOS 13.0.
	mapOptions.appearance = .automatic(light: lightTheme, dark: darkTheme)
} else {
	// Используем светлую тему в остальных случаях.
	mapOptions.appearance = .universal(lightTheme)
}

// Создаём карту с указанными настройками.
let mapFactory = sdk.makeMapFactory(options: mapOptions)
```

Изменить тему после создания карты можно с помощью свойства [appearance](/ru/ios/sdk/reference/2.0/IMapView#nav-lvl1--appearance) слоя карты:

```swift
// Слой карты.
let mapView = mapFactory.mapView

// Меняем тему на тёмную.
mapView.appearance = .universal(darkTheme)
```

## Распознаватель жестов карты

Для кастомизации распознавателя жестов карты, необходимо задать реализацию протокола [IMapGestureView](/ru/ios/sdk/reference/IMapGestureView) в [IMapView](/ru/ios/sdk/reference/IMapView) или реализацию [IMapGestureViewFactory](/ru/ios/sdk/reference/IMapGestureViewFactory) в [MapOptions](/ru/ios/sdk/reference/MapOptions).
Если ни одна из этих имплементаций задана не будет, то будет использована реализация по умолчанию.
Пример такой кастомизации распознавателя можно посмотреть [здесь](https://github.com/2gis/native-sdk-ios-demo/blob/master/app/Views/DemoPages/CustomGestures/CustomMapGestureView.swift).