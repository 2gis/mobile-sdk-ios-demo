## Getting started

To begin working with the SDK, create a [Container](/en/ios/sdk/reference/Container) object, which will store all map entities. To create it, you need to specify your API keys as an [APIKeys](/en/ios/sdk/reference/APIKeys) structure.

```swift
// Create an APIKeys object
guard let apiKeys = APIKeys(directory: "Directory API key", map: "SDK key") else { 
	fatalError("Invalid API keys.") 
}

// Create a Container object
let sdk = PlatformSDK.Container(apiKeys: apiKeys)
```

Additionally, you can specify logging settings ([LogOptions](/en/ios/sdk/reference/LogOptions)) and HTTP client settings ([HTTPOptions](/en/ios/sdk/reference/HTTPOptions)) such as timeout and caching.

```swift
// Logging settings
let logOptions = LogOptions(osLogLevel: .info)

// HTTP client settings
let httpOptions = HTTPOptions(timeout: 5, cacheOptions: nil)

// Geopositioning settings
let positioningServices: IPositioningServicesFactory = CustomPositioningServicesFactory()

// Consent to personal data processing
let dataCollectionOptions = DataCollectionOptions(dataCollectionStatus: .agree)

// Creating the Container
let sdk = PlatformSDK.Container(
	apiKeys: apiKeys,
	logOptions: logOptions,
	httpOptions: httpOptions,
	positioningServices: positioningServices,
	dataCollectionOptions: dataCollectionOptions
)
```

## Creating a map

To create a map, call the [makeMapFactory()](/en/ios/sdk/reference/Container#nav-lvl1--makeMapFactory) method and specify the required map settings as a [MapOptions](/en/ios/sdk/reference/MapOptions) structure.

It is important to specify the correct PPI settings for the device. You can find them in the [technical specification](https://support.apple.com/specs) of the device.

You can also specify the initial camera position, zoom limits, and other settings.

```swift
// Map settings object
var mapOptions = MapOptions.default

// PPI settings
mapOptions.devicePPI = devicePPI

// Create a map
let mapFactory: PlatformMapSDK.IMapFactory = sdk.makeMapFactory(options: mapOptions)
```

To get the view of the map, use the `mapView` property. To get the control of the map, use the [map](/en/ios/sdk/reference/Map) property.

```swift
// Map view
let mapView: UIView & IMapView = mapFactory.mapView

// Map control
let map = mapFactory.map
```

## General principles

### Deferred results

Some SDK methods (e.g., those that access a remote server) return deferred results ([Future](/en/ios/sdk/reference/Future)). To process a deferred result, you can specify two callback functions: completion and error. To move the execution to the main thread, you can use [DispatchQueue](https://developer.apple.com/documentation/dispatch/dispatchqueue).

For example, to get information from object directory, you can process [Future](/en/ios/sdk/reference/Future) like so:

```swift
// Create an object for directory search
let searchManager = SearchManager.createOnlineManager(context: sdk.context)

// Get object by identifier
let future = searchManager.searchByDirectoryObjectId(objectId: object.id)

// Process the search result in the main thread.
// Save the result to a property to prevent garbage collection.
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

To simplify working with deferred results, you can create an extension:

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

Or use the [Combine](https://developer.apple.com/documentation/combine) framework:

```swift
// Extension to convert PlatformSDK.Future to Combine.Future
extension PlatformSDK.Future {
	func asCombineFuture() -> Combine.Future<Value, Error> {
		Combine.Future { [self] promise in
			// Save the Cancellable object until the callback function is called.
			// Combine does not support cancelling Future directly.
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

// Create Combine.Future
let combineFuture = future.asCombineFuture()

// Process the search result in the main thread
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

### Data channels

Some SDK objects provide data channels (see the [Channel](/en/ios/sdk/reference/Channel) class). To subscribe to a data channel, you need to create and specify a handler function.

For example, you can subscribe to a visible rectangle channel, which is updated when the visible area of the map is changed:

```swift
// Choose a data channel
let visibleRectChannel = map.camera.visibleRectChannel

// Subscribe to the channel and process the results in the main thread.
// It is important to prevent the connection object from getting garbage collected to keep the subscription active.
self.cancellable = visibleRectChannel.sink { [weak self] visibleRect in
	DispatchQueue.main.async {
		self?.handle(visibleRect)
	}
}
```

When the data processing is no longer required, it is important to close the connection to avoid memory leaks. To do this, call the `cancel()` method:

```swift
self.cancellable.cancel()
```

You can create an extension to simplify working with data channels:

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

## Adding objects

To add dynamic objects to the map (such as markers, lines, circles, and polygons), you must first create a [MapObjectManager](/en/ios/sdk/reference/MapObjectManager) object by calling the [createMapObjectManager()](/en/ios/sdk/reference/createMapObjectManager(map%3A)) function and specifying the map instance. Deleting an object manager removes all associated objects from the map, so do not forget to save it to a property.

```swift
self.objectsManager = createMapObjectManager(map: map)
```

For each dynamic object, you can specify a `userData` field to store arbitrary data. Object settings can be changed after their creation.

### Marker

To add a marker to the map, call the [addMarker()](/en/ios/sdk/reference/MapObjectManager#nav-lvl1--addMarker) method and specify the required settings as a [MarkerOptions](/en/ios/sdk/reference/MarkerOptions) structure. The most important settings are the coordinates of the marker and its icon.

You can create an icon for the marker by calling the `make()` method and using [UIImage](https://developer.apple.com/documentation/uikit/uiimage), PNG data, or SVG markup as input.

```swift
// UIImage
let uiImage = UIImage(systemName: "umbrella.fill")!.withTintColor(.systemRed)
let icon = sdk.imageFactory.make(image: uiImage)

// SVG markup
let icon = sdk.imageFactory.make(svgData: imageData, size: imageSize)

// PNG data
let icon = sdk.imageFactory.make(pngData: imageData, size: imageSize)

// Marker settings
let options = MarkerOptions(
	position: GeoPointWithElevation(
		latitude: Arcdegree(value: 55.752425),
		longitude: Arcdegree(value: 37.613983)
	),
	icon: icon
)

// Add the marker to the map
let marker = objectsManager.addMarker(options: options)
```

To change the hotspot of the icon, use the [anchor](/en/ios/sdk/reference/Anchor) parameter.

### Line

To draw a line on the map, call the [addPolyline()](/en/ios/sdk/reference/MapObjectManager#nav-lvl1--addPolyline) method and specify the required settings as a [PolylineOptions](/en/ios/sdk/reference/PolylineOptions) structure.

In addition to the coordinates of the line points, you can set the line width, color, stroke type, and other options.

```swift
// Coordinates of the vertices of the polyline
let points = [
	GeoPoint(latitude: Arcdegree(value: 55.7513), longitude: Arcdegree(value: 37.6236)),
	GeoPoint(latitude: Arcdegree(value: 55.7405), longitude: Arcdegree(value: 37.6235)),
	GeoPoint(latitude: Arcdegree(value: 55.7439), longitude: Arcdegree(value: 37.6506))
]

// Line settings
let options = PolylineOptions(
	points: points,
	width: LogicalPixel(value: 2),
	color: PlatformSDK.Color.init()
)

// Add the line to the map
let polyline = objectsManager.addPolyline(options: options)
```

### Polygon

To draw a polygon on the map, call the [addPolygon()](/en/ios/sdk/reference/MapObjectManager#nav-lvl1--addPolygon) method and specify the required settings as a [PolygonOptions](/en/ios/sdk/reference/PolygonOptions) structure.

Coordinates for the polygon are specified as a two-dimensional array. The first subarray must contain the coordinates of the vertices of the polygon itself. The other subarrays are optional and can be specified to create a cutout (a hole) inside the polygon (one subarray - one polygonal cutout).

Additionally, you can specify the polygon color and stroke options.

```swift
let latLon = { (lat: Double, lon: Double) -> GeoPoint in
	return GeoPoint(latitude: Arcdegree(value: lat), longitude: Arcdegree(value: lon))
}

let polygon = self.objectManager.addPolygon(options: PolygonOptions(
	contours: [
		// Vertices of the polygon
		[
			latLon(55.72014932919687, 37.562599182128906),
			latLon(55.72014932919687, 37.67555236816406),
			latLon(55.78004852149085, 37.67555236816406),
			latLon(55.78004852149085, 37.562599182128906),
			latLon(55.72014932919687, 37.562599182128906)
		],
		// Cutout inside the polygon
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

## Controlling the camera

You can control the camera by accessing the `map.camera` property. See the [Camera](/en/ios/sdk/reference/Camera) class for a full list of available methods and properties.

### Changing camera position

You can change the position of the camera by calling the [move()](/en/ios/sdk/reference/Camera#nav-lvl1--move) method, which initiates a flight animation. This method has three parameters:

- `position` - new camera position (coordinates and zoom level). Additionally, you can specify the camera tilt and rotation (see [CameraPosition](/en/ios/sdk/reference/CameraPosition)).
- `time` - flight duration in seconds (as [TimeInterval](https://developer.apple.com/documentation/foundation/timeinterval)).
- `animationType` - type of animation to use ([CameraAnimationType](/en/ios/sdk/reference/CameraAnimationType)).

The call will return a [Future](/en/ios/sdk/reference/Future) object, which can be used to handle the animation finish event.

```swift
// New position for camera
let newCameraPosition = CameraPosition(
	point: GeoPoint(latitude: Arcdegree(value: 55.752425), longitude: Arcdegree(value: 37.613983)),
	zoom: Zoom(value: 16)
)

// Start the flight animation
let future = map.camera.move(
	position: newCameraPosition,
	time: 0.4,
	animationType: .linear
)

// Handle the animation finish event
let cancellable = future.sink { _ in
	print("Camera flight finished.")
} failure: { error in
	print("An error occurred: \(error.localizedDescription)")
}
```

### Getting camera state

The current state of the camera (i.e., whether the camera is currently in flight) can be obtained using the `state().value` property. See [CameraState](/en/ios/sdk/reference/CameraState) for a list of possible camera states.

```swift
let currentState = map.camera.state().value
```

You can subscribe to changes of camera state using the `state().sink` property.

```swift
// Subscribe to camera state changes
let connection = map.camera.state().sink { state in
	print("Camera state has changed to \(state)")
}

// Unsubscribe when it's no longer needed
connection.cancel()
```

### Getting camera position

The current position of the camera can be obtained using the `position().value` property (see the [CameraPosition](/en/ios/sdk/reference/CameraPosition) structure).

```swift
let currentPosition = map.camera.position().value
print("Coordinates: \(currentPosition.point)")
print("Zoom level: \(currentPosition.zoom)")
print("Tilt: \(currentPosition.tilt)")
print("Rotation: \(currentPosition.bearing)")
```

You can subscribe to changes of camera position using the `position().sink` property.

```swift
// Subscribe to camera position changes
let connection = positionChannel.sink { position in
	print("Camera position has changed (coordinates, zoom level, tilt, or rotation).")
}

// Unsubscribe when it's no longer needed
connection.cancel()
```

## My location

You can add a special marker to the map that will be automatically updated to reflect the current location of the device. To do this, create a data source using the [createMyLocationMapObjectSource()](/en/ios/sdk/reference/createMyLocationMapObjectSource(context%3AdirectionBehaviour%3A)) function and pass it to the [addSource()](/en/ios/sdk/reference/Map#nav-lvl1--addSource) method of the map.

```swift
// Create a data source
let source = createMyLocationMapObjectSource(
	context: sdk.context,
	directionBehaviour: MyLocationDirectionBehaviour.followMagneticHeading
)

// Add the data source to the map
map.addSource(source: source)
```

To remove the marker, call the [removeSource()](/en/ios/sdk/reference/Map#nav-lvl1--removeSource) method. You can get the list of active data sources by using the `map.sources` property.

```swift
map.removeSource(source)
```

## Getting objects using screen coordinates

You can get information about map objects using pixel coordinates. For this, call the [getRenderedObjects()](/en/ios/sdk/reference/Map#nav-lvl1--getRenderedObjects) method of the map and specify the pixel coordinates and the radius in screen millimeters. The method will return a deferred result ([Future](/en/ios/sdk/reference/Future)) containing information about all found objects within the specified radius on the visible area of the map (an array of [RenderedObjectInfo](/en/ios/sdk/reference/RenderedObjectInfo)).

An example of a function that takes tap coordinates and passes them to `getRenderedObjects()`:

```swift
private func tap(point: ScreenPoint, tapRadius: ScreenDistance) {
	let cancel = map.getRenderedObjects(centerPoint: point, radius: tapRadius).sink(
		receiveValue: {
			infos in
			// First array object is the closest to the coordinates
			guard let info = infos.first else { return }
			// Process the result in the main thread
			DispatchQueue.main.async {
				[weak self] in
				self?.handle(selectedObject: info)
			}
		},
		failure: { error in
			print("Error retrieving information: \(error)")
		}
	)
	// Save the result to a property to prevent garbage collection
	self.getRenderedObjectsCancellable = cancel
}
```

## Map styles

To work with map styles, you first need to create an [IStyleFactory](/en/ios/sdk/reference/IStyleFactory) object by calling the [makeStyleFactory()](/en/ios/sdk/reference/Container#nav-lvl1--makeStyleFactory) method.

```swift
let styleFactory = sdk.makeStyleFactory()
```

To create an SDK-compatible map style, use the Export function in [Style Editor](https://styles.2gis.com/) and add the downloaded file to your project.

### Using a map style

To create a map with a custom style, you need to use the [loadResource()](/en/ios/sdk/reference/IStyleFactory#nav-lvl1--loadResource) or [loadFile()](/en/ios/sdk/reference/IStyleFactory#nav-lvl1--loadFile) method of [IStyleFactory](/en/ios/sdk/reference/IStyleFactory) and specify the resulting object as the `styleFuture` map option.

```swift
// Create a style factory object
let styleFactory = sdk.makeStyleFactory()

// Set the map style in map settings
var mapOptions = MapOptions.default
mapOptions.styleFuture = styleFactory.loadResource(name: "custom_style_file.2gis", bundle: .main)

// Create a map with the specified settings
let mapFactory = sdk.makeMapFactory(options: mapOptions)
```

The [loadResource()](/en/ios/sdk/reference/IStyleFactory#nav-lvl1--loadResource) and [loadFile()](/en/ios/sdk/reference/IStyleFactory#nav-lvl1--loadFile) methods return a deferred result ([Future](/en/ios/sdk/reference/Future)) so as not to delay the loading of the map. If the style has already been loaded (see the next section for more details), you can convert it into a [Future](/en/ios/sdk/reference/Future) object using the [makeReadyValue()](/en/ios/sdk/reference/Future#nav-lvl1--makeReadyValue) method.

```swift
var mapOptions = MapOptions.default
mapOptions.styleFuture = Future.makeReadyValue(style)
```

### Changing the map style

To change the style of an existing map, use the [setStyle()](/en/ios/sdk/reference/Map#nav-lvl1--setStyle) method.

Unlike the `styleFuture` map option, [setStyle()](/en/ios/sdk/reference/Map#nav-lvl1--setStyle) accepts a fully loaded [Style](/en/ios/sdk/reference/Style) object instead of a [Future](/en/ios/sdk/reference/Future) object. Therefore, [setStyle()](/en/ios/sdk/reference/Map#nav-lvl1--setStyle) should be called after the [Future](/en/ios/sdk/reference/Future) has been resolved.

```swift
// Create a style factory object
let styleFactory = sdk.makeStyleFactory()

// Load a new map style. The loadFile() method only accepts the file:// URI scheme.
self.cancellable = styleFactory.loadFile(url: styleFileURL).sink(
	receiveValue: { [map = self.map] style in
		// After the style has been loaded, use it to change the current map style.
		map.setStyle(style: style)
	},
	failure: { error in
		print("Failed to load style from <\(fileURL)>. Error: \(error)")
	})
```

### Dark Mode

Each map style can contain several themes that you can switch between without having to load an additional style. You can specify which theme to use by setting the [appearance](/en/ios/sdk/reference/MapOptions#nav-lvl1--appearance) map option when creating the map.

In iOS 13.0 and later, you can also use the automatic switching between light and dark themes (see [Dark Mode](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/dark-mode)).

```swift
// Map settings
var mapOptions = MapOptions.default

// Name of the light theme
let lightTheme: Theme = "day"

// Name of the dark theme
let darkTheme: Theme = "night"

if #available(iOS 13.0, *) {
	// Automatically switch between the light and dark themes
	mapOptions.appearance = .automatic(light: lightTheme, dark: darkTheme)
} else {
	// Use only the light theme
	mapOptions.appearance = .universal(lightTheme)
}

// Create a map with the specified settings
let mapFactory = sdk.makeMapFactory(options: mapOptions)
```

To change the theme after the map has been created, use the `appearance` property of [IMapView](/en/ios/sdk/reference/IMapView):

```swift
// Get the map view
let mapView = mapFactory.mapView

// Change the theme to dark
mapView.appearance = .universal(darkTheme)
```
