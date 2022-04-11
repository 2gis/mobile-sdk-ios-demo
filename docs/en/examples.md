## Getting started

To begin working with the SDK, create a [Container](/en/ios/sdk/reference/2.0/Container) object, which will store all map entities. To create it, you need to specify your API keys as an [APIKeys](/en/ios/sdk/reference/2.0/APIKeys) structure.

```swift
// Create an APIKeys object
guard let apiKeys = APIKeys(directory: "Directory API key", map: "SDK key") else { 
	fatalError("Invalid API keys.") 
}

// Create a Container object
let sdk = DGis.Container(apiKeys: apiKeys)
```
Note that DGis.Container can be created in single instance.

Additionally, you can specify logging settings ([LogOptions](/en/ios/sdk/reference/2.0/LogOptions)) and HTTP client settings ([HTTPOptions](/en/ios/sdk/reference/2.0/HTTPOptions)) such as timeout and caching.

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
let sdk = DGis.Container(
	apiKeys: apiKeys,
	logOptions: logOptions,
	httpOptions: httpOptions,
	positioningServices: positioningServices,
	dataCollectionOptions: dataCollectionOptions
)
```

## Creating a map

To create a map, call the [makeMapFactory()](/en/ios/sdk/reference/2.0/Container#nav-lvl1--makeMapFactory) method and specify the required map settings as a [MapOptions](/en/ios/sdk/reference/2.0/MapOptions) structure.

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

To get the view of the map, use the `mapView` property. To get the control of the map, use the [map](/en/ios/sdk/reference/2.0/Map) property.

```swift
// Map view
let mapView: UIView & IMapView = mapFactory.mapView

// Map control
let map = mapFactory.map
```

## General principles

### Deferred results

Some SDK methods (e.g., those that access a remote server) return deferred results ([Future](/en/ios/sdk/reference/2.0/Future)). To process a deferred result, you can specify two callback functions: completion and error. To move the execution to the main thread, you can use [DispatchQueue](https://developer.apple.com/documentation/dispatch/dispatchqueue).

For example, to get information from object directory, you can process [Future](/en/ios/sdk/reference/2.0/Future) like so:

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

Or use the [Combine](https://developer.apple.com/documentation/combine) framework:

```swift
// Extension to convert DGis.Future to Combine.Future
extension DGis.Future {
	func asCombineFuture() -> Combine.Future<Value, Error> {
		Combine.Future { [self] promise in
			// Save the Cancellable object until the callback function is called.
			// Combine does not support cancelling Future directly.
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

Some SDK objects provide data channels (see the [Channel](/en/ios/sdk/reference/2.0/Channel) class). To subscribe to a data channel, you need to create and specify a handler function.

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

## Adding objects

To add dynamic objects to the map (such as markers, lines, circles, and polygons), you must first create a [MapObjectManager](/en/ios/sdk/reference/2.0/MapObjectManager) object, specifying the map instance. Deleting an object manager removes all associated objects from the map, so do not forget to save it to a property.

```swift
self.objectsManager = MapObjectManager(map: map)
```

After you have created an object manager, you can add objects to the map using the [addObject()](/en/ios/sdk/reference/2.0/MapObjectManager#nav-lvl1--addObject) and [addObjects()](/en/ios/sdk/reference/2.0/MapObjectManager#nav-lvl1--addObjects) methods. For each dynamic object, you can specify a `userData` field to store arbitrary data. Object settings can be changed after their creation.

To remove objects from the map, use [removeObject()](/en/ios/sdk/reference/2.0/MapObjectManager#nav-lvl1--removeObject) and [removeObjects()](/en/ios/sdk/reference/2.0/MapObjectManager#nav-lvl1--removeObjects). To remove all objects, call the [removeAll()](/en/ios/sdk/reference/2.0/MapObjectManager#nav-lvl1--removeAll) method.

### Marker

To add a marker to the map, create a [Marker](/en/ios/sdk/reference/2.0/Marker) object, specifying the required options ([MarkerOptions](/en/ios/sdk/reference/2.0/MarkerOptions)), and pass it to the `addObject()` method of the object manager. The most important settings are the coordinates of the marker and its icon.

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
		latitude: 55.752425,
		longitude: 37.613983
	),
	icon: icon
)

// Create and add the marker to the map
let marker = Marker(options: options)
objectManager.addObject(object: marker)
```

To change the hotspot of the icon, use the [anchor](/en/ios/sdk/reference/2.0/Anchor) parameter.

### Line

To draw a line on the map, create a [Polyline](/en/ios/sdk/reference/2.0/Polyline) object, specifying the required options, and pass it to the `addObject()` method of the object manager.

In addition to the coordinates of the line points, you can set the line width, color, stroke type, and other options (see [PolylineOptions](/en/ios/sdk/reference/2.0/PolylineOptions)).

```swift
// Coordinates of the vertices of the polyline
let points = [
	GeoPoint(latitude: 55.7513, longitude: value: 37.6236),
	GeoPoint(latitude: 55.7405, longitude: value: 37.6235),
	GeoPoint(latitude: 55.7439, longitude: value: 37.6506)
]

// Line settings
let options = PolylineOptions(
	points: points,
	width: LogicalPixel(value: 2),
	color: DGis.Color.init()
)

// Create and add the line to the map
let polyline = Polyline(options: options)
objectManager.addObject(object: polyline)
```

### Polygon

To draw a polygon on the map, create a [Polygon](/en/ios/sdk/reference/2.0/Polygon) object, specifying the required options, and pass it to the `addObject()` method of the object manager.

Coordinates for the polygon are specified as a two-dimensional array. The first subarray must contain the coordinates of the vertices of the polygon itself. The other subarrays are optional and can be specified to create a cutout (a hole) inside the polygon (one subarray - one polygonal cutout).

Additionally, you can specify the polygon color and stroke options (see [PolygonOptions](/en/ios/sdk/reference/2.0/PolygonOptions)).

```swift
// Polygon settings
let options = PolygonOptions(
	contours: [
		// Vertices of the polygon
		[
			GeoPoint(latitude: 55.72014932919687, longitude: 37.562599182128906),
			GeoPoint(latitude: 55.72014932919687, longitude: 37.67555236816406),
			GeoPoint(latitude: 55.78004852149085, longitude: 37.67555236816406),
			GeoPoint(latitude: 55.78004852149085, longitude: 37.562599182128906),
			GeoPoint(latitude: 55.72014932919687, longitude: 37.562599182128906)
		],
		// Cutout inside the polygon
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

// Create and add the polygon to the map
let polygon = Polygon(options: options)
objectManager.addObject(object: polygon)
```

### Clustering

To add markers to the map in clustering mode, you must create a [MapObjectManager](/en/ios/sdk/reference/2.0/MapObjectManager) object using [MapObjectManager.withClustering()](/en/ios/sdk/reference/2.0/MapObjectManager#nav-lvl1--withClustering), specifying the map instance, distance between clusters in logical pixels, maximum value of zoom-level, when MapObjectManager in clustering mode, and user implementation of the protocol SimpleClusterRenderer.
[SimpleClusterRenderer](/en/ios/sdk/reference/2.0/SimpleClusterRenderer) is used to customize clusters in [MapObjectManager](/en/ios/sdk/reference/2.0/MapObjectManager).

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

## Controlling the camera

You can control the camera by accessing the `map.camera` property. See the [Camera](/en/ios/sdk/reference/2.0/Camera) class for a full list of available methods and properties.

### Changing camera position

You can change the position of the camera by calling the [move()](/en/ios/sdk/reference/2.0/Camera#nav-lvl1--move) method, which initiates a flight animation. This method has three parameters:

- `position` - new camera position (coordinates and zoom level). Additionally, you can specify the camera tilt and rotation (see [CameraPosition](/en/ios/sdk/reference/2.0/CameraPosition)).
- `time` - flight duration in seconds (as [TimeInterval](https://developer.apple.com/documentation/foundation/timeinterval)).
- `animationType` - type of animation to use ([CameraAnimationType](/en/ios/sdk/reference/2.0/CameraAnimationType)).

The call will return a [Future](/en/ios/sdk/reference/2.0/Future) object, which can be used to handle the animation finish event.

```swift
// New position for camera
let newCameraPosition = CameraPosition(
	point: GeoPoint(latitude: 55.752425, longitude: 37.613983),
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

The current state of the camera (i.e., whether the camera is currently in flight) can be obtained using the `state` property. See [CameraState](/en/ios/sdk/reference/2.0/CameraState) for a list of possible camera states.

```swift
let currentState = map.camera.state
```

You can subscribe to changes of camera state using the `stateChannel.sink` property.

```swift
// Subscribe to camera state changes
let connection = map.camera.stateChannel.sink { state in
	print("Camera state has changed to \(state)")
}

// Unsubscribe when it's no longer needed
connection.cancel()
```

### Getting camera position

The current position of the camera can be obtained using the `position` property (see the [CameraPosition](/en/ios/sdk/reference/2.0/CameraPosition) structure).

```swift
let currentPosition = map.camera.position
print("Coordinates: \(currentPosition.point)")
print("Zoom level: \(currentPosition.zoom)")
print("Tilt: \(currentPosition.tilt)")
print("Rotation: \(currentPosition.bearing)")
```

You can subscribe to changes of camera position using the `positionChannel.sink` property.

```swift
// Subscribe to camera position changes
let connection = map.camera.positionChannel.sink { position in
	print("Camera position has changed (coordinates, zoom level, tilt, or rotation).")
}

// Unsubscribe when it's no longer needed
connection.cancel()
```

## My location

You can add a special marker to the map that will be automatically updated to reflect the current location of the device. To do this, create a data source using the [createMyLocationMapObjectSource()](/en/ios/sdk/reference/2.0/createMyLocationMapObjectSource(context%3AdirectionBehaviour%3A)) function and pass it to the [addSource()](/en/ios/sdk/reference/2.0/Map#nav-lvl1--addSource) method of the map.

```swift
// Create a data source
let source = createMyLocationMapObjectSource(
	context: sdk.context,
	directionBehaviour: MyLocationDirectionBehaviour.followMagneticHeading
)

// Add the data source to the map
map.addSource(source: source)
```

To remove the marker, call the [removeSource()](/en/ios/sdk/reference/2.0/Map#nav-lvl1--removeSource) method. You can get the list of active data sources by using the `map.sources` property.

```swift
map.removeSource(source)
```

## Turn-by-turn navigation

You can add a turn-by-turn navigation to your app using the ready-to-use interface components ([INavigationView](/en/ios/sdk/reference/2.2/INavigationView)) and the [NavigationManager](/en/ios/sdk/reference/2.2/NavigationManager) class.

To do that, add a [My location marker](#nav-lvl1--My_location) to the map and create a navigation layer using [INavigationViewFactory](/en/ios/sdk/reference/2.2/INavigationViewFactory) and [NavigationManager](/en/ios/sdk/reference/2.2/NavigationManager).

```swift
// Create a map object
guard let mapFactory = try? sdk.makeMapFactory(options: .default) else {
    return
}

// Add the map view to the view hierarchy
let mapView = mapFactory.mapView
mapView.translatesAutoresizingMaskIntoConstraints = false
containerView.addSubview(mapView)
NSLayoutConstraint.activate([
    mapView.leftAnchor.constraint(equalTo: containerView.leftAnchor),
    mapView.rightAnchor.constraint(equalTo: containerView.rightAnchor),
    mapView.topAnchor.constraint(equalTo: containerView.topAnchor),
    mapView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
])

// Add the current location marker to the map
let locationSource = MyLocationMapObjectSource(
    context: sdk.context,
    directionBehaviour: .followSatelliteHeading,
    controller: createSmoothMyLocationController()
)
let map = mapFactory.map
map.addSource(source: locationSource)

// Create a NavigationManager object
let navigationManager = NavigationManager(platformContext: sdk.context)

// Attach the map to the NavigationManager
navigationManager.mapManager.addMap(map: map)

// Create a NavigationViewFactory object
let navigationViewFactory = sdk.makeNavigationViewFactory()

// Create a navigation view and add it to the view hierarchy above the map
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

// Add an event handler for the close button
navigationView.closeButtonCallback = {
    navigationManager.stop()
}
```

You can start navigation in one of three modes: free-drive, turn-by-turn, and the simulated navigation mode.

Additional navigation settings can be changed using the properties of the [NavigationManager](/en/ios/sdk/reference/2.2/NavigationManager#nav-lvl1--uiModel) object.

### Free-drive mode

In free-drive mode, no route will be displayed on the map, but the user will still be informed about speed limits, traffic cameras, incidents, and road closures.

To start navigation in this mode, call the `start()` method without arguments.

```swift
navigationManager.start()
```

### Turn-by-turn mode

In turn-by-turn mode, a route will be displayed on the map and the user will receive navigation instructions as they move along the route.

To start navigation in this mode, call the `start()` method and specify a [RouteBuildOptions](/en/ios/sdk/reference/2.2/RouteBuildOptions) object - arrival coordinates and route settings.

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

Additionally, when calling the `start()` method, you can specify a [TrafficRoute](/en/ios/sdk/reference/2.2/TrafficRoute) object - a complete route object for navigation. In this case, [NavigationManager](/en/ios/sdk/reference/2.2/NavigationManager) will use the specified route instead of building a new one.

```swift
// Building a route
self.routeSearchCancellable = routesFuture.sink { routes in
    guard let route = routes.first else { return }

    // Route settings
    let routeBuildOptions = RouteBuildOptions(
        finishPoint: finishPoint,
        routeSearchOptions: routeSearchOptions
    )
    // Start navigation
    navigationManager.start(
        routeBuildOptions: routeBuildOptions,
        trafficRoute: route
    )
} failure: { error in
    print("Couldn't build the route: \\(error)")
}
```

### Simulated navigation

In this mode, [NavigationManager](/en/ios/sdk/reference/2.2/NavigationManager) will not track the current location of the device. Instead, it will simulate a movement along the specified route.

This mode is useful for debugging.

To use this mode, call the `startSimulation()` method and specify a [RouteBuildOptions](/en/ios/sdk/reference/2.2/RouteBuildOptions) object (route settings) and a [TrafficRoute](/en/ios/sdk/reference/2.2/TrafficRoute) object (the route itself).

You can change the speed of the simulated movement using the [SimulationSettings.speed](/en/ios/sdk/reference/2.2/SimulationSettings) property (specified in meters per second).

```swift
navigationManager.simulationSettings.speed = 30 / 3.6
navigationManager.startSimulation(
    routeBuildOptions: routeBuildOptions,
    trafficRoute: route
)
```

To stop the simulation, call the `stop()` method.

```swift
navigationManager.stop()
```

## Getting objects using screen coordinates

You can get information about map objects using pixel coordinates. For this, call the [getRenderedObjects()](/en/ios/sdk/reference/2.0/Map#nav-lvl1--getRenderedObjects) method of the map and specify the pixel coordinates and the radius in screen millimeters. The method will return a deferred result ([Future](/en/ios/sdk/reference/2.0/Future)) containing information about all found objects within the specified radius on the visible area of the map (an array of [RenderedObjectInfo](/en/ios/sdk/reference/2.0/RenderedObjectInfo)).

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

To work with map styles, you first need to create an [IStyleFactory](/en/ios/sdk/reference/2.0/IStyleFactory) object by calling the [makeStyleFactory()](/en/ios/sdk/reference/2.0/Container#nav-lvl1--makeStyleFactory) method.

```swift
let styleFactory = sdk.makeStyleFactory()
```

To create an SDK-compatible map style, use the Export function in [Style Editor](https://styles.2gis.com/) and add the downloaded file to your project.

### Using a map style

To create a map with a custom style, you need to use the [loadResource()](/en/ios/sdk/reference/2.0/IStyleFactory#nav-lvl1--loadResource) or [loadFile()](/en/ios/sdk/reference/2.0/IStyleFactory#nav-lvl1--loadFile) method of [IStyleFactory](/en/ios/sdk/reference/2.0/IStyleFactory) and specify the resulting object as the `styleFuture` map option.

```swift
// Create a style factory object
let styleFactory = sdk.makeStyleFactory()

// Set the map style in map settings
var mapOptions = MapOptions.default
mapOptions.styleFuture = styleFactory.loadResource(name: "custom_style_file.2gis", bundle: .main)

// Create a map with the specified settings
let mapFactory = sdk.makeMapFactory(options: mapOptions)
```

The [loadResource()](/en/ios/sdk/reference/2.0/IStyleFactory#nav-lvl1--loadResource) and [loadFile()](/en/ios/sdk/reference/2.0/IStyleFactory#nav-lvl1--loadFile) methods return a deferred result ([Future](/en/ios/sdk/reference/2.0/Future)) so as not to delay the loading of the map. If the style has already been loaded (see the next section for more details), you can convert it into a [Future](/en/ios/sdk/reference/2.0/Future) object using the [makeReadyValue()](/en/ios/sdk/reference/2.0/Future#nav-lvl1--makeReadyValue) method.

```swift
var mapOptions = MapOptions.default
mapOptions.styleFuture = Future.makeReadyValue(style)
```

### Changing the map style

To change the style of an existing map, use the [setStyle()](/en/ios/sdk/reference/2.0/Map#nav-lvl1--setStyle) method.

Unlike the `styleFuture` map option, [setStyle()](/en/ios/sdk/reference/2.0/Map#nav-lvl1--setStyle) accepts a fully loaded [Style](/en/ios/sdk/reference/2.0/Style) object instead of a [Future](/en/ios/sdk/reference/2.0/Future) object. Therefore, [setStyle()](/en/ios/sdk/reference/2.0/Map#nav-lvl1--setStyle) should be called after the [Future](/en/ios/sdk/reference/2.0/Future) has been resolved.

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

Each map style can contain several themes that you can switch between without having to load an additional style. You can specify which theme to use by setting the [appearance](/en/ios/sdk/reference/2.0/MapOptions#nav-lvl1--appearance) map option when creating the map.

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

To change the theme after the map has been created, use the `appearance` property of [IMapView](/en/ios/sdk/reference/2.0/IMapView):

```swift
// Get the map view
let mapView = mapFactory.mapView

// Change the theme to dark
mapView.appearance = .universal(darkTheme)
```

## Map gesture recognizer

To customize the map gesture recognizer, you need to set the [IMapGestureView](/en/ios/sdk/reference/IMapGestureView) implementation in [IMapView](/en/ios/sdk/reference/IMapView) or [IMapGestureViewFactory](/en/ios/sdk/reference/IMapGestureViewFactory) implementation in [MapOptions](/en/ios/sdk/reference/MapOptions).
If no implementations are specified, the default implementations will be used.
An example of such recognizer is available [here](https://github.com/2gis/native-sdk-ios-demo/blob/master/app/Views/DemoPages/CustomGestures/CustomMapGestureView.swift).
