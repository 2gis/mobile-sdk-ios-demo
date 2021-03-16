# Работа с маркерами

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
	self.hideSelectedMarker()
	self.getRenderedObjectsCancellable?.cancel()

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
