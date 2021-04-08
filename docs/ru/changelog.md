# Release notes

## v0.10
**Release Date:** 07.04.2021
- добавили метод takeSnapshot для получения последнего отрисованного кадра в картинку
- removeSource больше не бросает исключение. Даже если источник не был добавлен на карту
- добавили полилинию с градиентом
- *Ломающее изменение:* обновили класс GeoRect
- *Ломающее изменение:* мы изменили формат работы с подписками на изменения свойств. Раньше такие поля как camera.position имели тип StatefulChannel. Для того чтобы получать уведомления об изменениях данных в Channel нужно вызвать camera.position.sync(), а получить текущее значение можно через camera.position.value. Такой API вызывал вопросы, поэтому в новой версии camera.position(и другие свойства StatefulChannel) это просто getter/setter. А для подписки на изменение нужно использовать camera.positionChannel


## v0.9
**Release Date:** 24.03.2021
- добавили возможность рисовать [пунктирную линию](/ru/ios/native/maps/reference/PolylineOptions#nav-lvl1--dashed)
- [opacity](/ru/ios/native/maps/reference/Marker#nav-lvl1--iconOpacity) для Marker
- функции конверторы для работы со Style Zoom([projectionZToStyleZ](/ru/ios/native/maps/reference/projectionZToStyleZ(map%3AprojectionZ%3Alatitude%3A)), [styleZToProjectionZ](/ru/ios/native/maps/reference/styleZToProjectionZ(map%3AstyleZ%3Alatitude%3A)))
- для работы с атрибутами карты добавлен новый тип [AttributeValue](/ru/ios/native/maps/reference/AttributeValue)
- из [DgisMapObject](/ru/ios/native/maps/reference/DgisMapObject) больше нельзя получить Future на объект справочника. Для этого нужно использовать [SearchManager](/ru/ios/native/maps/reference/SearchManager)
- [настройки HTTP-клиента](/ru/ios/native/maps/reference/HTTPOptions): время ожидания, наличие и размер дискового кеша
- возможность задавать собственные реализации сервисов геопозиционироваания или отключать их (например, для симулятора)


## v0.8
**Release Date:** 17.03.2021
- добавили кэш для тайлов на карте. Возможность конфигурировать размер кэша появится в следующем релизе
- [Padding](/ru/ios/native/maps/reference/Map#nav-lvl1--padding) на карте
- для объектов Polygon/Polyline добавилась возможность изменить текущую геометрию
- добавили источник для растровых тайлов(см. [createRasterTileDataSource](/ru/ios/native/maps/reference/createRasterTileDataSource(context%3AsublayerName%3AurlTemplate%3A)))
- поддержали атрибут theme для стилей карты выгруженных из редактора