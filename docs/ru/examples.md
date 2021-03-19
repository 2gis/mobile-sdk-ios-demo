## Инициализации

*// TODO: инициализация SDK, работа с ключами*

## Общая информация
### Future
*// TODO: в каких потоках срабатывают*

*// TODO: как сшить с кастомными Future*


### Channel
*// TODO: в каких потоках срабатывают*

*// TODO: как сшить с кастомными Future*


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

// соединение необходимо сохранять до тех пор пока необходимо получать уведомления
// когда эта информация больше не нужна подписку стоит разорвать
connection.cancel()
```
### Отслеживание состояния камеры
Карта может находится в нескольких состояниях перечисленных в [CameraState](/ru/ios/native/maps/reference/CameraState). 
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
	directionBehaviour: MyLocationDirectionBehaviour.followMagneticHeading)

// добавляем источник в карту
map.addSource(source: source)
```

## Динамические объекты на карте
В большенстве случаев для добавления объектов следует использовать [MapObjectManager](/ru/ios/native/maps/reference/MapObjectManager). Он предоствляет простой интерфейс для работы с высокоуровневыми примитивами
### Marker
*// TODO: создание Image*

добавление маркера на карту
```swift
let objectsManager = createMapObjectManager(map: map)

let options = MarkerOptions(
	position: GeoPointWithElevation(
		latitude: Arcdegree(value: 55.752425),
		longitude: Arcdegree(value: 37.613983)
	),
	icon: imageFactory.make(image: icon)
)

let marker = objectsManager.addMarker(options: options)
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
