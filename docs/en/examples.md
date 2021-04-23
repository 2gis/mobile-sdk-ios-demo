## Инициализация
### Создание контейнера SDK
```swift
// Создание набора ключей для доступа к сервисам.
guard let apiKeys = APIKeys(directory: directoryAPIKey, map: mapAPIKey) else { 
	fatalError("API keys are empty or have incorrect format") 
}

// Создание контейнера для доступа к возможностям SDK в конфигурации по умолчанию.
let sdk = PlatformSDK.Container(apiKeys: self.apiKeys)
```
### Создание контейнера SDK с пользовательскими настройками.
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
	apiKeys: self.apiKeys,
	logOptions: logOptions,
	httpOptions: httpOptions,
	positioningServices: positioningServices,
	dataCollectionOptions: dataCollectionOptions
)
```


## Создание карты
```swift
// Создание набора ключей для доступа к сервисам.
guard let apiKeys = APIKeys(directory: directoryAPIKey, map: mapAPIKey) else { 
	fatalError("API keys are empty or have incorrect format") 
}

// Создание контейнера для доступа к возможностям SDK.
let sdk = PlatformMapSDK.Container(apiKeys: apiKeys)

// Свойства карты.
var mapOptions = MapOptions.default

// Важно установить корректное для устройства значение PPI.
// Значение PPI можно найти в [спецификации устройства](https://www.apple.com/iphone-11/specs/).
mapOptions.devicePPI = devicePPI

// Получаем фабрику объектов карты.
let mapFactory: PlatformMapSDK.IMapFactory = sdk.makeMapFactory(options: mapOptions)

// Получаем слой карты.
let mapView: UIView & IMapView = mapFactory.mapView
```


## Общая информация
### Работа с отложенными результатами ([Future](en/ios/native/maps/reference/Future))
#### Работа с очередями (`DispatchQueue`)
**Обработчики Future вызываются на произвольной очереди, если документация не заявляет обратного.**
```swift
// Создание онлайн поисковика.
let searchManager = SearchManager.createOnlineManager(context: self.sdk.context)

// Получение объекта справочника по идентификатору.
let future = searchManager.searchByDirectoryObjectId(objectId: object.id)

// Обработка результата поиска в главной очереди.
// Сохраняем результат вызова `sink`, так как его уничтожение обрывает подписку.
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
```swift
// С помощью расширения улучшаем интеграцию с `DispatchQueue`.
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

// Упрощенный вариант получения результатов на главной очереди.
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
#### Работа с Combine
```swift
// Создание Combine.Future из PlatformSDK.Future.
extension PlatformSDK.Future {
	func asCombineFuture() -> Combine.Future<Value, Error> {
		Combine.Future { [self] promise in
			// Keep cancellable reference until either handler is called.
			// Combine.Future does not directly handle cancellation.
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

// Получение объекта справочника по идентификатору.
let future = searchManager.searchByDirectoryObjectId(objectId: object.id)

// Создаем Combine.Future.
let combineFuture = future.asCombineFuture()

// Обработка результа поиска на главной очереди.
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
### Работа с потоками значений ([Channel](en/ios/native/maps/reference/Channel))
#### Работа с очередями (`DispatchQueue`)
**Обработчик Channel по умолчанию вызываются на произвольной очереди, если документация не заявляет обратного.**
```swift
// Поток значений — прямоугольников видимой области карты.
// Значения будут присылаться при любом изменении видимой области до момента отписки.
let visibleRectChannel = self.map.camera.visibleRectChannel

// Подписываемся и обрабатываем результаты на главной очереди.
// Важно сохранить Cancellable, иначе подписка будет уничтожена.
self.cancellable = visibleRectChannel.sink { [weak self] visibleRect in
	DispatchQueue.main.async {
		self?.handle(visibleRect)
	}
}
```
```swift
// С помощью расширения улучшаем интеграцию с `DispatchQueue`.
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

// Подписываемся и обрабатываем результаты на главной очереди.
self.cancellable = visibleRectChannel.sinkOnMainThread { [weak self] visibleRect in
	self?.handle(visibleRect)
}
```


## Камера
### Перелет
```swift
// Новое положение камеры.
let newCameraPosition = CameraPosition(
	point: GeoPoint(latitude: Arcdegree(value: 55.752425), longitude: Arcdegree(value: 37.613983)),
	zoom: Zoom(value: 16)
)

// Запуск перелета.
let future = map.camera.move(
	position: newCameraPosition,
	time: 0.4,
	animationType: .linear
)

// Так же можно получить уведомление когда перелет закончен.
let cancellable = future.sink { _ in
	print("Camera position is changed successfully")
} failure: { error in
	print("Something went wrong: \(error.localizedDescription)")
}
```
### Отслеживание позиции камеры
```swift
let positionChannel = map.camera.position()

// Получить текущее значение позиции камеры.
let currentPosition = positionChannel.value

// Подписаться на изменения.
let connection = positionChannel.sink { position in
	print("Geo coordinate \(position.point)")
	print("Zoom level \(position.zoom)")
	print("Tilt \(position.tilt)")
	print("Bearing \(position.bearing)")
}

// Соединение необходимо сохранять, пока необходимо получать уведомления.
// Когда эта информация больше не нужна, подписку стоит разорвать,
// уничтожив объект подписки или вызвав у него cancel().
connection.cancel()
```
### Отслеживание состояния камеры
Карта может находится в состояниях, перечисленных в [CameraState](/ru/ios/native/maps/reference/CameraState).
```swift
// Получить текущее состояние.
let currentState = map.camera.state().value

// Подписаться на изменение.
let cancellable = map.camera.state().sink { state in
	print("new state is \(state)")
}
```


## Мое местоположение

### Маркер местоположения на карте
```swift
// Создаем источник для отображения маркера на карте.
let source = createMyLocationMapObjectSource(
	context: sdkContext,
	directionBehaviour: MyLocationDirectionBehaviour.followMagneticHeading
)

// Добавляем источник в карту.
map.addSource(source: source)
```

## Динамические объекты на карте
В большинстве случаев для добавления объектов следует использовать [MapObjectManager](/ru/ios/native/maps/reference/MapObjectManager). Он предоставляет высокоуровневый интерфейс для работы с объектами карты.
### Marker
Создание иконки
```swift
// На основе UIImage.
let uiImage = UIImage(systemName: "umbrella.fill")!.withTintColor(.systemRed)
let icon = sdk.imageFactory(image: uiImage)

// На основе PNG-данных (быстрее).
let icon = sdk.imageFactory(pngData: imageData, size: imageSize)
```
добавление маркера на карту
```swift
// Записываем объект в свойство, так как во время удаления `objectsManager`
// исчезают все связанные с ним объекты на карте.
self.objectsManager = createMapObjectManager(map: sdk.map)

let options = MarkerOptions(
	position: GeoPointWithElevation(
		latitude: Arcdegree(value: 55.752425),
		longitude: Arcdegree(value: 37.613983)
	),
	icon: sdk.imageFactory.make(image: uiImage)
)

let marker = objectsManager.addMarker(options: options)
// Можем донастроить только что созданый `marker`, если необходимо.
```

### Polyline
```swift
let points = [
	GeoPoint(latitude: Arcdegree(value: 55.7513), longitude: Arcdegree(value: 37.6236)),
	GeoPoint(latitude: Arcdegree(value: 55.7405), longitude: Arcdegree(value: 37.6235)),
	GeoPoint(latitude: Arcdegree(value: 55.7439), longitude: Arcdegree(value: 37.6506))
]

let options = PolylineOptions(
	points: points,
	width: LogicalPixel(value: 2),
	color: PlatformSDK.Color.init(),
	userData: "Any user data object"
)

let polyline = objectsManager.addPolyline(options: options)
```

### Polygon
// TBD


## Получение информации о точке прикосновения к карте

Передаём точку нажатия в пиксельных координатах. Для наиболее подходящего
объекта в заданном радиусе будет вызван метод `self.handle(selectedObject:)`.

Подписка на результат `getRenderedObjects` возвращает значение
в произвольной очереди, поэтому в примере перемещаем итоговый
вызов в главную очередь.

Значение `cancel` сохраняется в свойство `getRenderedObjectsCancellable`,
потому что уничтожение `Cancellable`-объекта приводит к немедленной отмене
подписки на `Future<T>`.

```
/// - Parameter point: A tap point in *pixel* (native scale) cooordinates.
/// - Parameter tapRadius: Radius around tap point in which objects will
///   be detected.
private func tap(point: ScreenPoint, tapRadius: ScreenDistance) {
	let cancel = self.map.getRenderedObjects(centerPoint: point, radius: tapRadius).sink(
		receiveValue: {
			infos in
			// The first object is the closest one to the tapped point.
			guard let info = infos.first else { return }
			DispatchQueue.main.async {
				[weak self] in
				self?.handle(selectedObject: info)
			}
		},
		failure: { error in
			print("Failed to fetch objects: \(error)")
		}
	)
	self.getRenderedObjectsCancellable = cancel
}
```
