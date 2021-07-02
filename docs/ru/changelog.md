# Release notes


## v0.16.1
**Release Date:** 07.06.2021
- Обновлены стандартные стили карты - исправлены размеры надписей и иконок.

## v0.16.0
**Release Date:** 02.06.2021
- При создании объектов карты появилась возможность задавать порядок их отрисовки через `MarkerOptions.zIndex`, `PolygonOptions.zIndex` и т.д. Значение индекса влияет на приоритет объекта при наложении элементов на карте.
- Упрощение создания простых типов данных: `Arcdegree`, `Color`, `Elevation`, `GeoPoint`, `GeoPointWithElevation`, `LogicalPixel`, `Meter`, `Tilt` и `Zoom`.

  Например, раньше при создании объекта типа `GeoPoint` необходимо было конструировать объекты типа `Arcdegree`.

  `let geoPoint = GeoPoint(latitude: Arcdegree(value: 54.0), longitude: Arcdegree(value: 32.0))`

  Теперь доступна инициализация `GeoPoint` из пары значений `CLLocationDegrees`.

  `let geoPoint = GeoPoint(latitude: 54.0, longitude: 32.0)`.

- Добавлена возможность задавать список локалей в обход системных настроек с помощью `LocaleManager.setOverridedLocales`. Для возврата к системным локалям необходимо передать пустой список в метод `LocaleManager.setOverridedLocales`.
- Добавлена функция `toMapGeometry(trafficRoute:currentRoutePoint:)` для получения геометрии оставшейся части маршрута.
- Исправлено отображение карты при нулевом z-уровне.
- Добавлена возможность отключения анимации при появлении или исчезновении объектов на карте через `MarkerOptions.animatedAppearance` и `Marker.setAnimatedAppearance`.
- Поддержана установка корректного DPI при создании карты. Теперь помимо установки DPI через `MapOptions.devicePPI` можно задать `MapOptions.deviceDensity` - множитель, равный числу физических пикселей устройства в одной логической точке экранной системы координат. Из-за того, что deviceDensity не устанавливался, объекты на карте на различных z-уровнях имели некорректные размеры.

  Например, для заданного экрана (`UIScreen`) этот множитель равен значению `nativeScale`. По умолчанию берется `nativeScale` главного экрана.
- *Ломающее изменение*. Удален устаревший класс `MarkerBuilder` для создания объектов карты. Вместо него нужно использовать класс `MapObjectManager` для добавления объектов; конструкторы `Marker`, `Polygon` и т.д. для их создания.

## v0.15.0
**Release Date:** 25.05.2021
- Добавлена возможность проверки пересечения геометрий - `Geometry.hasIntersection`.
- В `SearchResult` добавлен признак `autoUseFirstResult`, который обозначает, что первый элемент поисковой выдачи наиболее подходит для перелета или построения маршрута к нему.
- Исправлена ошибка в механизме сетевого кеширования, приводящая к медленной записи сетевых ответов на файловую систему устройства.
- *Ломающее изменение*. Изменение интерфейса `MapObjectManager`.

  Теперь объекты карты создаются через конструкторы `Marker`, `Polygon` и т.д. вместо `MapObjectManager.addMarker` или `MapObjectManager.addPolygon`.

  Для добавления или удаления объектов карты теперь нужно использовать методы `MapObjectManager.addObject/addObjects/removeObject` и т.д. При добавлении нескольких объектов эффективнее всего использовать `MapObjectManager.addObjects`.
- *Ломающее изменение*. Изменён порядок параметров функций `calcPosition` и `zoomOutToFit`.
- *Ломающее изменение*. Настройка сервиса сбора данных `DataCollectStatus` переименована в `PersonalDataCollectionConsent`.
- *Ломающее изменение*. В конструкторе `Container` параметр `dataCollectStatus` также переименован в `personalDataCollectionConsent`.

## v0.14.0
**Release Date:** 05.05.2021
- Исправлена ошибка при добавлении маркера на карту через `MapObjectManager`.
  
  По умолчанию маркер был направлен на север. Это приводило к тому, что его угол поворота зависел от угла поворота карты.
  
  Теперь маркер направлен к верху экрана устройства независимо от поворота карты.
- *Ломающее изменение*. Изначальный поворот маркера (`MarkerOptions.iconMapDirection`) и поворот существующего маркера (`Marker.iconMapDirection`) теперь имеют зануляемый тип `MapDirection?`.
  
  Нулевое значение означает, что маркер будет направлен к верху экрана устройства независимо от поворота карты.

## v0.13.0
**Release Date:** 30.04.2021
- Добавлена возможность задать поворот маркера. Изначальный поворот — `MarkerOptions.iconMapDirection`; поворот существующего маркера — `Marker.iconMapDirection`.
- В копирайте на карте по умолчанию не отображается версия SDK. Чтобы включить, нужно установить `MapView.showsAPIVersion` в `true`.
- Добавлена возможность получения местоположения и направления камер в навигаторе: `Camera.geoPoint`, `Camera.bearing`.
- Добавлена возможность задать точку местоположения (`positionPoint`) в функциях `calcPosition` и `zoomOutToFit`.
- *Ломающее изменение*. Многие функции создания объектов заменены на инициализаторы соответствующего типа.
  Например: `createMapObjectManager` → `MapObjectManager.init`; `Geometry.createPoint` → `PointGeometry.init` и т.д.

## v0.12.2
**Release Date:** 24.04.2021
- Исправлены параметры при сборе статистики.

## v0.12.1
**Release Date:** 23.04.2021
- Исправлено отображение карты на разных масштабах.
- Исправлен механизм сбора статистики.
- Исправлена проблема с маркерами, при которой они вытесняли друг друга на разных масштабах.
- Установлено минимальное значение zoom-левела равное 2.

## v0.12
**Release Date:** 22.04.2021
- Исправлено потенциальное падение при передаче `MapOptions` с ненулевым `styleFuture`
  в `Container.makeMapFactory(options:)`.
- Исправлено потенциальное падение при уничтожении объектов карты (`IMapFactory`).
- Устранена утечка одного объекта при полном уничтожении контейнера SDK.
- Улучшена обработка объектов `CLLocation` в реализациях протокола `ILocationProvider`.

  Прежде, если местоположение содержало одновременно корректные и некорректные компоненты
  (например, имеются геокоординаты, но отсутствует значение скорости), объект
  не учитывался целиком. Это сопровождалось сообщением `Platform sent an invalid location` в журнале.
  
  Теперь в таком случае учитываются верные компоненты. Сообщение пишется тогда,
  когда в SDK передаётся полностью некорректное местоположение.
- Добавлено автоопределение PPI карты на основании модели головного устройства. См. `DevicePpi.autodetected`.
  Настройки карты по умолчанию (`MapOptions.default`) используют этот PPI; а в случае неподдерживаемого устройства
  проставляется `DevicePpi.defaultForFailedAutodetection`.
- Тип `DevicePpi` теперь реализует протокол `ExpressibleByFloatLiteral`.
- Добавлена возможность задавать тему карты и включать автопереключение темы на iOS 13.

  Новый тип `Theme` соответствует теме в рамках стиля. Новый тип `MapAppearance` указывает
  набор тем и способ их применения: `.universal` для фиксированной темы; `.automatic`
  для автопереключения между светлой и тёмной темой на iOS 13.

  Настройку тем можно задать в `MapOptions.appearance` при создании объектов
  карты вызовом `Container.makeMapFactory(options:)`. Последующее
  переключение доступно установкой свойства `IMapView.appearance`.
- *Ломающее изменение*. Тип `MapOptions.devicePpi` изменился c `CGFloat?` на `DevicePpi?` в целях улучшения документации.
- Добавлен сбор анонимной статистики использования. По умолчанию включён.
  См. параметр `dataCollectionOptions` у `Container.init`.  
  Отключать рекомендуется только в случае явного выбора пользователем (например, отказ GDPR).

## v0.11
**Release Date:** 15.04.2021
- Управление и получение информации о HTTP-кеше — `HttpCacheManager`.
- Нестатические свойства большинства структур сделаны изменяемыми (т.е. `let` → `var`).
- Информация о полосах движения маршрута - `RouteInfo.laneSigns`.
- Убрана тонкая черная граница у объектов карты, когда она не задана.
- Типы `ScreenPoint`, `ScreenSize`, `ScreenShift` реализуют `Equatable` и `Hashable`.
- Добавлены конструкторы `ScreenPoint(_: CGPoint)`, `ScreenSize(_: CGSize)`, `ScreenShift(_: CGVector)`.
- *Ломающиее изменение:* `TextStyle.fontSize`, `TextStyle.strokeWidth` имеют тип `LogicalPixel`, а не `Float`.
- *Ломающиее изменение:* В модели навигатора: вместо `Model.laneSign` теперь `Model.laneSignIndex`.
  `LaneSign` можно получить по этому индексу из `RouteInfo.laneSigns`.
- *Ломающее изменение:* Метод для создания пользовательского слоя обработки жестов принимает меньшее число парамтеров: `IMapGestureViewFactory.makeGestureView(map:coordinateSpace:)`. Убран параметр `eventProcessor`: вместо него нужно использовать метод `Map.processEvent`.

## v0.10
**Release Date:** 07.04.2021
- добавили инструмент для получения последнего отрисованного кадра карты в виде изображения — `IMapFactory.snapshotter.makeImage()`
- removeSource больше не бросает исключение. Даже если источник не был добавлен на карту
- добавили полилинию с градиентом
- cоздание пользовательского слоя распознавания жестов теперь возможно при инициализации карты, см. `gestureViewFactory` у `MapOptions`
- *Ломающее изменение:* изменили устройство типов, связанных с картой. Теперь карту нужно создавать вызовом `Container.makeMapFactory(options:) -> IMapFactory`. Из него доступен контроллер карты — `map`, вид карты `mapView` и прочие вещи.
- *Ломающее изменение:* обновили класс GeoRect
- *Ломающее изменение:* мы изменили формат работы с подписками на изменения свойств. Раньше такие поля как `Map.camera.position` имели тип `StatefulChannel`. Прежде получали уведомления об изменениях значений свойств с помощью `camera.position.sink(receiveValue:)`, а текущее значение через `camera.position.value`. Такой API вызывал трудности и был менее эффективен, поэтому в новой версии, например, `camera.position` — это просто свойство типа `CameraPosition`; а `camera.positionChannel` — `StatefulChannel<CameraPosition>. Это изменение в силе для всех свойств, ранее имевших тип `StatefulChannel`.


## v0.9
**Release Date:** 24.03.2021
- добавили возможность рисовать [пунктирную линию](/ru/ios/sdk/reference/PolylineOptions#nav-lvl1--dashed)
- [opacity](/ru/ios/sdk/reference/Marker#nav-lvl1--iconOpacity) для Marker
- функции конверторы для работы со Style Zoom([projectionZToStyleZ](/ru/ios/sdk/reference/projectionZToStyleZ(map%3AprojectionZ%3Alatitude%3A)), [styleZToProjectionZ](/ru/ios/sdk/reference/styleZToProjectionZ(map%3AstyleZ%3Alatitude%3A)))
- для работы с атрибутами карты добавлен новый тип [AttributeValue](/ru/ios/sdk/reference/AttributeValue)
- из [DgisMapObject](/ru/ios/sdk/reference/DgisMapObject) больше нельзя получить Future на объект справочника. Для этого нужно использовать [SearchManager](/ru/ios/sdk/reference/SearchManager)
- [настройки HTTP-клиента](/ru/ios/sdk/reference/HTTPOptions): время ожидания, наличие и размер дискового кеша
- возможность задавать собственные реализации сервисов геопозиционироваания или отключать их (например, для симулятора)


## v0.8
**Release Date:** 17.03.2021
- добавили кэш для тайлов на карте. Возможность конфигурировать размер кэша появится в следующем релизе
- [Padding](/ru/ios/sdk/reference/Map#nav-lvl1--padding) на карте
- для объектов Polygon/Polyline добавилась возможность изменить текущую геометрию
- добавили источник для растровых тайлов(см. [createRasterTileDataSource](/ru/ios/sdk/reference/createRasterTileDataSource(context%3AsublayerName%3AurlTemplate%3A)))
- поддержали атрибут theme для стилей карты выгруженных из редактора
