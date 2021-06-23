## Начало работы

Для работы с SDK нужно создать специальный объект [Container](/ru/ios/sdk/reference/Container), который будет хранить все сущности, связанные с картой.

Чтобы его создать, нужно указать набор ключей доступа к SDK в виде структуры [APIKeys](/ru/ios/sdk/reference/APIKeys).

```swift
// Набор ключей для доступа к сервисам.
guard let apiKeys = APIKeys(directory: "Directory API key", map: "SDK key") else { 
	fatalError("Указанные API-ключи недействительны.") 
}

// Создание контейнера для доступа к возможностям SDK.
let sdk = PlatformSDK.Container(apiKeys: apiKeys)
```

Дополнительно можно указать настройки журналирования ([LogOptions](/ru/ios/sdk/reference/LogOptions)) и настройки HTTP-клиента ([HTTPOptions](/ru/ios/sdk/reference/HTTPOptions)), такие как время ожидания ответа и кеширование.

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
let sdk = PlatformSDK.Container(
	apiKeys: apiKeys,
	logOptions: logOptions,
	httpOptions: httpOptions,
	positioningServices: positioningServices,
	dataCollectionOptions: dataCollectionOptions
)
```

## Создание карты

Чтобы создать карту, нужно вызвать метод [makeMapFactory()](/ru/ios/sdk/reference/Container#nav-lvl1--makeMapFactory) и передать настройки карты в виде структуры [MapOptions](/ru/ios/sdk/reference/MapOptions).

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

Получить слой карты можно через свойство `mapView`. Контроллер карты доступен через свойство `map` (см. класс [Map](/ru/ios/sdk/reference/Map)).

```swift
// Слой карты.
let mapView: UIView & IMapView = mapFactory.mapView

// Контроллер карты.
let map = mapFactory.map
```

## Общие принципы работы

### Работа с отложенными результатами

Некоторые методы SDK (например те, которые обращаются к удаленному серверу) возвращают отложенные результаты (объект [Future](/ru/ios/sdk/reference/Future)). Для работы с ними нужно создать обработчик получения данных и обработчик ошибок. Обработать результат в главной очереди можно с помощью [DispatchQueue](https://developer.apple.com/documentation/dispatch/dispatchqueue).

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
extension PlatformSDK.Future {
	func sinkOnMainThread(
		receiveValue: @escaping (Value) -> Void,
		failure: @escaping (Error) -> Void
	) -> PlatformSDK.Cancellable {
		self.sink(on: .main, receiveValue: receiveValue, failure: failure)
	}

	func sink(
		on queue: DispatchQueue,
		receiveValue: @escaping (Value) -> Void,
		failure: @escaping (Error) -> Void
	) -> PlatformSDK.Cancellable {
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
// Создание Combine.Future из PlatformSDK.Future
extension PlatformSDK.Future {
	func asCombineFuture() -> Combine.Future<Value, Error> {
		Combine.Future { [self] promise in
			// Удерживаем ссылку на Cancellable, пока не будет вызван обработчик
			// Combine.Future не позволяет конфигурировать отмену напрямую
			var cancellable: PlatformSDK.Cancellable?
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

Некоторые объекты SDK предоставляют потоки значений, которые можно обработать, используя механизм каналов: на поток можно подписаться, указав функцию-обработчик данных, и отписаться, когда обработка данных больше не требуется. Для работы с потоками значений используется класс [Channel](/ru/ios/sdk/reference/Channel).

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
	func sinkOnMainThread(receiveValue: @escaping (Value) -> Void) -> PlatformSDK.Cancellable {
		self.sink(on: .main, receiveValue: receiveValue)
	}

	func sink(on queue: DispatchQueue, receiveValue: @escaping (Value) -> Void) -> PlatformSDK.Cancellable {
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

Для добавления динамических объектов на карту (маркеров, линий, кругов, многоугольников) нужно создать менеджер объектов ([MapObjectManager](/ru/ios/sdk/reference/MapObjectManager)), вызвав функцию [createMapObjectManager()](/ru/ios/sdk/reference/createMapObjectManager(map%3A)) и указав инстанс карты.

```swift
// Сохраняем объект в свойство, так как при удалении менеджера исчезают все связанные с ним объекты на карте.
self.objectsManager = createMapObjectManager(map: map)
```

Для каждого динамического объекта можно указать поле `userData`, которое будет хранить произвольные данные, связанные с объектом.

Настройки объектов можно менять после их создания.

### Маркер

Чтобы добавить маркер на карту, нужно вызвать метод [addMarker()](/ru/ios/sdk/reference/MapObjectManager#nav-lvl1--addCircle) менеджера объектов и указать настройки маркера в виде структуры [MarkerOptions](/ru/ios/sdk/reference/MarkerOptions). В настройках важно указать координаты маркера и его иконку.

Иконку для маркера можно создать с помощью метода `make()` фабрики изображений ([IImageFactory](/ru/ios/sdk/reference/IImageFactory)), используя [UIImage](https://developer.apple.com/documentation/uikit/uiimage), PNG-данные или SVG-разметку.

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
		latitude: Arcdegree(value: 55.752425),
		longitude: Arcdegree(value: 37.613983)
	),
	icon: icon
)

// Создание маркера.
let marker = objectsManager.addMarker(options: options)
```

Чтобы изменить точку привязки иконки (выравнивание иконки относительно координат на карте), нужно указать параметр [anchor](/ru/ios/sdk/reference/Anchor).

### Линия

Чтобы нарисовать на карте линию, нужно вызвать метод [addPolyline()](/ru/ios/sdk/reference/MapObjectManager#nav-lvl1--addPolyline) и указать настройки линии в виде структуры [PolylineOptions](/ru/ios/sdk/reference/PolylineOptions).

Кроме массива координат для точек линии, в настройках можно указать ширину линии, цвет, параметры пунктира и обводки.

```swift
// Координаты вершин ломаной линии.
let points = [
	GeoPoint(latitude: Arcdegree(value: 55.7513), longitude: Arcdegree(value: 37.6236)),
	GeoPoint(latitude: Arcdegree(value: 55.7405), longitude: Arcdegree(value: 37.6235)),
	GeoPoint(latitude: Arcdegree(value: 55.7439), longitude: Arcdegree(value: 37.6506))
]

// Настройки линии.
let options = PolylineOptions(
	points: points,
	width: LogicalPixel(value: 2),
	color: PlatformSDK.Color.init()
)

// Создание линии.
let polyline = objectsManager.addPolyline(options: options)
```

### Многоугольник

Чтобы нарисовать на карте многоугольник, нужно вызвать метод [addPolygon()](/ru/ios/sdk/reference/MapObjectManager#nav-lvl1--addPolygon) и указать настройки многоугольника в виде структуры [PolygonOptions](/ru/ios/sdk/reference/PolygonOptions).

Координаты для многоугольника указываются в виде двумерного массива. Первый вложенный массив должен содержать координаты основных вершин многоугольника. Остальные вложенные массивы не обязательны и могут быть заданы для того, чтобы создать вырез внутри многоугольника (один дополнительный массив - один вырез в виде многоугольника).

Важно указать координаты таким образом, чтобы первое и последнее значение в каждом массиве совпадало. Иными словами, ломаная должна быть замкнутой.

Дополнительно можно указать цвет полигона и параметры обводки.

```swift
let latLon = { (lat: Double, lon: Double) -> GeoPoint in
	return GeoPoint(latitude: Arcdegree(value: lat), longitude: Arcdegree(value: lon))
}

let polygon = self.objectManager.addPolygon(options: PolygonOptions(
	contours: [
		// Вершины многоугольника.
		[
			latLon(55.72014932919687, 37.562599182128906),
			latLon(55.72014932919687, 37.67555236816406),
			latLon(55.78004852149085, 37.67555236816406),
			latLon(55.78004852149085, 37.562599182128906),
			latLon(55.72014932919687, 37.562599182128906)
		],
		// Координаты выреза внутри многоугольника.
		[
			latLon(55.754167897761, 37.62422561645508),
			latLon(55.74450654680055, 37.61238098144531),
			latLon(55.74460317215391, 37.63435363769531),
			latLon(55.754167897761, 37.62422561645508)
		]
	],
	color: PlatformSDK.Color.init(),
	strokeWidth: LogicalPixel(value: 2)
))
```

## Управление камерой

Для работы с камерой используется объект [Camera](/ru/ios/sdk/reference/Camera), доступный через свойство `map.camera`.

### Перелёт

Чтобы запустить анимацию перелёта камеры, нужно вызвать метод [move()](/ru/ios/sdk/reference/Camera#nav-lvl1--move) и указать параметры перелёта:

- `position` - конечная позиция камеры (координаты и уровень приближения). Дополнительно можно указать наклон и поворот камеры (см. [CameraPosition](/ru/ios/sdk/reference/CameraPosition)).
- `time` - продолжительность перелёта в секундах ([TimeInterval](https://developer.apple.com/documentation/foundation/timeinterval)).
- `animationType` - тип анимации ([CameraAnimationType](/ru/ios/sdk/reference/CameraAnimationType)).

Функция `move()` возвращает объект [Future](/ru/ios/sdk/reference/Future), который можно использовать, чтобы обработать событие завершения перелета.

```swift
// Новая позиция камеры.
let newCameraPosition = CameraPosition(
	point: GeoPoint(latitude: Arcdegree(value: 55.752425), longitude: Arcdegree(value: 37.613983)),
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

Текущее состояние камеры (находится ли камера в полёте) можно получить, используя свойство `state().value`. См. [CameraState](/ru/ios/sdk/reference/CameraState) для списка возможных состояний камеры.

```swift
let currentState = map.camera.state().value
```

Подписаться на изменения состояния камеры можно, используя `state().sink`.

```swift
// Подписка.
let connection = map.camera.state().sink { state in
	print("Состояние камеры изменилось на \(state)")
}

// Отписка.
connection.cancel()
```

### Получение позиции камеры

Текущую позицию камеры можно получить, используя свойство `position().value` (см. структуру [CameraPosition](/ru/ios/sdk/reference/CameraPosition)).

```swift
let currentPosition = map.camera.position().value
print("Координаты: \(currentPosition.point)")
print("Приближение: \(currentPosition.zoom)")
print("Наклон: \(currentPosition.tilt)")
print("Поворот: \(currentPosition.bearing)")
```

Подписаться на изменения позиции камеры (и угла наклона/поворота) можно, используя `position().sink`.

```swift
// Подписка.
let connection = positionChannel.sink { position in
	print("Изменилась позиция камеры или угол наклона/поворота.")
}

// Отписка.
connection.cancel()
```

## Моё местоположение

На карту можно добавить специальный маркер, который будет отражать текущее местоположение устройства. Для этого нужно создать источник данных, вызвав [createMyLocationMapObjectSource()](/ru/ios/sdk/reference/createMyLocationMapObjectSource(context%3AdirectionBehaviour%3A)) и указав контейнер объектов SDK (`sdk.context`). Созданный источник нужно передать в метод карты [addSource()](/ru/ios/sdk/reference/Map#nav-lvl1--addSource).

```swift
// Создание источника данных.
let source = createMyLocationMapObjectSource(
	context: sdk.context,
	directionBehaviour: MyLocationDirectionBehaviour.followMagneticHeading
)

// Добавление маркера на карту.
map.addSource(source: source)
```

Чтобы удалить маркер, нужно вызвать метод [removeSource()](/ru/ios/sdk/reference/Map#nav-lvl1--removeSource). Список активных источников данных можно получить, используя свойство `map.sources`.

```swift
map.removeSource(source)
```

## Получение объектов по экранным координатам

Информацию об объектах на карте можно получить, используя пиксельные координаты. Для этого нужно вызвать метод карты [getRenderedObjects()](/ru/ios/sdk/reference/Map#nav-lvl1--getRenderedObjects), указав координаты в пикселях и радиус в экранных миллиметрах. Метод вернет отложенный результат, содержащий информацию обо всех найденных объектах в указанном радиусе на видимой области карты (массив [RenderedObjectInfo](/ru/ios/sdk/reference/RenderedObjectInfo)).

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

## Пользовательские стили карты

Для работы со стилями необходимо создать экземпляр [IStyleFactory](/ru/ios/sdk/reference/IStyleFactory) (см. метод [makeStyleFactory()](/ru/ios/sdk/reference/Container#nav-lvl1--makeStyleFactory)).
Методы [loadFile](/ru/ios/sdk/reference/IStyleFactory#nav-lvl1--loadFile) и [loadResource](/ru/ios/sdk/reference/IStyleFactory#nav-lvl1--loadResource) получают ссылку на файл пакета стилей (см. [Экспорт стиля](/en/mapgl/styles/overview/mobile-sdk#nav-lvl2--iOS_SDK)). Возвращают [Future](/ru/ios/sdk/reference/Future) с отложенно загружаемым экземпляром стиля.
### Создание карты с пользовательским стилем
```swift
// Настройки карты.
var mapOptions = MapOptions.default

// Создание фабрики стилей.
let styleFactory = sdk.makeStyleFactory()

// Устанавливаем начальный стиль карты с отложенной загрузкой.
mapOptions.styleFuture = styleFactory.loadResource(name: "custom_style_file.2gis", bundle: .main)

// Создание фабрики объектов карты.
let mapFactory = sdk.makeMapFactory(options: mapOptions)

// Объект карты, использующий пользовательский стиль.
let map = mapFactory.map
```

Можно использовать уже загруженный стиль: 
```swift
// Настройки карты.
var mapOptions = MapOptions.default

// Устанавливаем начальный стиль, передав Future с заранее загруженным стилем.
mapOptions.styleFuture = Future.makeReadyValue(style)
```
### Изменение стиля карты

Для смены стиля карты используется метод `setStyle()` контроллера карты (см. [Map](/ru/ios/sdk/reference/Map#nav-lvl1--setStyle)):
```swift
// Создание фабрики стилей.
let styleFactory = sdk.makeStyleFactory()

// Создание фабрики объектов карты.
let mapFactory = sdk.makeMapFactory(options: mapOptions)

// Загружаем новый стиль карты. Можно использовать только файловые URL (file://).
self.cancellable = styleFactory.loadFile(url: styleFileURL).sink(
	receiveValue: { [map = self.map] style in
		// Меняем активный стиль карты.
		map.setStyle(style: style)
	},
	failure: { error in
		print("Failed to load style from <\(fileURL)>. Error: \(error)")
	})
```

### Настройка темы

Тему стиля карты можно указать при создании новой карты или в уже существующей.
При создании карты тема указывается с помощью свойства `appearance` объекта [MapOptions](/ru/ios/sdk/reference/MapOptions#nav-lvl1--appearance), передаваемого в [makeMapFactory](/ru/ios/sdk/reference/Container#nav-lvl1--makeMapFactory).
В уже существующей карте тема меняется с помощью свойства `IMapView.appearance`.

Пример создания карты с заданной темой:
```swift
// Настройки карты.
var mapOptions = MapOptions.default

// Светлая тема в используемом стиле.
let lightTheme: Theme = "day"

// Темная тема в используемом стиле.
let darkTheme: Theme = "night"

if #available(iOS 13.0, *) {
	// Устанавливаем внешний вид карты, автоматически переключающий тему в соответствии с изменением окружения.
	options.appearance = .automatic(light: lightTheme, dark: darkTheme)
} else {
	// Устанавливаем внешний вид карты, использующий единую тему текущего стиля в любом окружении.
	options.appearance = .universal(lightTheme)
}

// Создание фабрики объектов карты.
let mapFactory = sdk.makeMapFactory(options: mapOptions)
```
Смена темы карты:
```swift
// Слой карты.
let mapView = mapFactory.mapView

// Изменяем внешний вид карты, устанавливая темную тему.
mapView.appearance = .universal(darkTheme)
```
