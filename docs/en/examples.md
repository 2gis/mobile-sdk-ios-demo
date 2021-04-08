## Начало работы

Для запуска примера:
1. Склонируйте [GitHub-репозиторий 2GIS](https://github.com/2gis/native-sdk-ios-demo).
2. Откройте проект `app.xcodeproj` и задайте ваши ключи API в файле `Info.plist` проекта:

   ```
   dgisMapApiKey=YOUR_MAP_KEY
   dgisDirectoryApiKey=YOUR_DIRECTIONS_KEY
   ```

3. Дождитесь загрузки зависимостей Swift. Эта операция может занять длительное время.

   Вы не сможете собрать и запустить проект, пока не будут загружены зависимости.
 
4. Соберите и запустите проект (⌘+R).

## Инициализации
```swift
// создание набора ключей для доступа к сервисам
let apiKeys = APIKeys(directory: directoryAPIKey, map: mapAPIKey)
// создание контейнера для доступа к возможностям SDK в конфигурации по умолчанию
let sdk = PlatformSDK.Container(apiKeys: self.apiKeys)

// конфигурирование контейнера SDK

// настройки журналирования
let logOptions = LogOptions(osLogLevel: .info)
// настройки HTTP-клиента 
let httpOptions = HTTPOptions(timeout: 5, cacheOptions: nil)
// cервисы геопозиционирования
let positioningServices: IPositioningServicesFactory = CustomPositioningServicesFactory()
// создание контейнера
let sdk = PlatformSDK.Container(
	apiKeys: self.apiKeys,
	logOptions: logOptions,
	httpOptions: httpOptions,
	positioningServices: positioningServices
)
```


## Общая информация
### [Future](en/ios/native/maps/reference/Future)
#### Работа с потоками
```swift
// получение объект справочника по идентификатору
let future = searchManager.searchByDirectoryObjectId(objectId: object.id)

// обработка результа поиска на главном потоке
let searchDirectoryObjectCancellable = future.sink(
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

// с помощью расширения можно упростить работу с очередью обратного вызова
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

// упрощенный вариант получения результатов на главном потоке 
let searchDirectoryObjectCancellable = future.sinkOnMainThread(
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
// создание Combine.Future из PlatformSDK.Future
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

// получение объект справочника по идентификатору
let future = searchManager.searchByDirectoryObjectId(objectId: object.id)

// создаем Combine.Future
let combineFuture = future.asCombineFuture()
// обработка результа поиска на главном потоке
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
### [Channel](en/ios/native/maps/reference/Channel)
#### Работа с потоками
```swift
// канал получения информации о прямоугольнике области просмотра
let visibleRectChannel = self.map.camera.visibleRectChannel
// подписываемся и обрабатываем результаты на главном потоке
self.cancellable = visibleRectChannel.sink { [weak self] visibleRect in
	DispatchQueue.main.async {
		self?.handle(visibleRect)
	}
}

// с помощью расширения так же можно упростить работу с очередями
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

// подписываемся и обрабатываем результаты на главном потоке
self.cancellable = visibleRectChannel.sinkOnMainThread { [weak self] visibleRect in
	self?.handle(visibleRect)
}
```


## Камера
### Перелет
```swift
// новое положение камеры
let newCameraPosition = CameraPosition(
	point: GeoPoint(latitude: Arcdegree(value: 55.752425), longitude: Arcdegree(value: 37.613983)),
	zoom: Zoom(value: 16)
)

// запуск перелета
let future = map.camera.move(
	position: newCameraPosition,
	time: 0.4,
	animationType: .linear
)

// так же можно получить уведомление когда перелет закончен
let cancellable = future.sink { _ in
	print("Camera position is changed successfully")
} failure: { error in
	print("Something went wrong: \(error.localizedDescription)")
}
```
### Отслеживание позиции камеры
```swift
let positionChannel = map.camera.position()

// получить текущее значение позиции камеры
let currentPosition = positionChannel.value

// подписаться на изменения
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
// получить текущее состояние
let currentState = map.camera.state().value

// подписаться на изменение
let cancellable = map.camera.state().sink { state in
	print("new state is \(state)")
}
```


## Мое местоположение

### Маркер местоположения на карте
```swift
// создаем источник для отображения маркера на карте
let source = createMyLocationMapObjectSource(
	context: sdkContext,
	directionBehaviour: MyLocationDirectionBehaviour.followMagneticHeading
)

// добавляем источник в карту
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
