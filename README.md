# 2GIS iOS SDK

2GIS iOS SDK allows you to add a [2GIS map](https://2gis.ae/) to your iOS application. It can be used to display the map in your layout, add custom markers to it, draw geometric shapes, calculate and display routes, get information about map objects, control the camera movement, and so on.

Geodata complies with [OGC standards](https://en.wikipedia.org/wiki/Open_Geospatial_Consortium).

## Getting API keys

Usage of this SDK requires an API key to connect to 2GIS servers and retrieve the geographical data. This API key is unique to the SDK and cannot be used with other 2GIS SDKs.

Additionally, if you plan to draw routes on the map or get extra information about map objects, you will need a separate key - a Directory API key.

To obtain either of these API keys, fill in the form at [dev.2gis.com](https://dev.2gis.com/order/).

## System requirements

- Xcode 12+
- iOS 13.0+ / iPadOS 13.0+ (this SDK uses [SwiftUI](https://developer.apple.com/documentation/swiftui))

You can also use [xcframework](https://github.com/2gis/mobile-sdk-map-swift-package/blob/master/Package.swift) to build your project for iOS 12.

## Installation

To install this SDK, you need to add a package dependency to your project. See the [official documentation](https://developer.apple.com/documentation/swift_packages/adding_package_dependencies_to_your_app) for more information on using Swift packages.

2GIS iOS SDK is distributed in two versions: full and lite. The lite version does not include the routes and navigation functionality.

Specify one of the following URLs when adding a dependency to install the SDK:

- `https://github.com/2gis/mobile-sdk-map-swift-package` - to get the lite version.
- `https://github.com/2gis/mobile-sdk-full-swift-package` - to get the full version.

## Running the demo app

To run the demo app, do the following:

1. Clone this repository.
2. Open the `app.xcodeproj` project and set your API keys in `Info.plist`:

   ```
   DGISMapAPIKey = YOUR_MAP_KEY
   DGISDirectoryAPIKey = YOUR_DIRECTORY_KEY
   ```

   Alternatively, create a file named `Local.xcconfig` in the repository root (this file is included in .gitignore):

   ```
   DGIS_MAP_API_KEY = xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
   DGIS_DIRECTORY_API_KEY = xxxxxxxxxx
   ```

   API keys are not mandatory. You can keep the placeholder values if you don't need the corresponding functionality.

3. Wait for Swift Package Manager to finish installing all dependencies (this could take a while).

   You won't be able to build the project until the dependencies are installed.

4. Build and run the project (⌘+R).

## Documentation

Full documentation, including [usage examples](https://docs.2gis.com/en/ios/sdk/examples) and [API reference](https://docs.2gis.com/en/ios/sdk/reference/Container) with detailed descriptions of all classes and methods, can be found at [docs.2gis.com](https://docs.2gis.com/en/ios/sdk/overview).

## License

The demo application is licensed under the BSD 2-Clause "Simplified" License. See the [LICENSE](https://github.com/2gis/native-sdk-ios-demo/blob/master/LICENSE) file for more information.
